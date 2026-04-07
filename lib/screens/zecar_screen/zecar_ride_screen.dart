import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zepay_app/config/google_maps_config.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/models/ride_option_model.dart';
import 'package:zepay_app/screens/zecar_screen/widgets/zecar_map_placeholder.dart';
import 'package:zepay_app/screens/zecar_screen/zecar_ride_confirmation_screen.dart';
import 'package:zepay_app/screens/zecar_screen/zecar_ride_sheet_widgets.dart';
import 'package:zepay_app/screens/zecar_screen/zecar_sheet_metrics.dart';

/// ZeCar / ZeRide: full-bleed map (or placeholder) + draggable ride sheet.
///
/// Prefer [ZecarTripPlanningScreen] for the main flow (same map, in-place sheet).
/// This screen remains for direct entry or tests.
class ZecarRideScreen extends StatefulWidget {
  const ZecarRideScreen({
    super.key,
    this.pickupAddress = 'Current location',
    this.destinationAddress = '',
  });

  final String pickupAddress;
  final String destinationAddress;

  static const double sheetInitialExtent =
      ZecarSheetMetrics.chooseRideSheetExtent;

  @override
  State<ZecarRideScreen> createState() => _ZecarRideScreenState();
}

class _ZecarRideScreenState extends State<ZecarRideScreen> {
  static const LatLng _kDefaultPickup = LatLng(-6.1944, 106.8229);
  static const LatLng _kDefaultDrop = LatLng(-6.2250, 106.8010);

  late LatLng _pickupLatLng;
  late LatLng _dropLatLng;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final TransformationController _placeholderMapPan =
      TransformationController();

  GoogleMapController? _mapController;
  late String _selectedRideId;

  @override
  void initState() {
    super.initState();
    _pickupLatLng = _kDefaultPickup;
    _dropLatLng = _kDefaultDrop;
    _selectedRideId = RideOptionsMock.recommended.first.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveRouteFromAddresses();
    });
  }

  static bool _isCurrentLocationPlaceholder(String s) {
    final t = s.trim().toLowerCase();
    return t.isEmpty || t == 'current location';
  }

  Future<void> _resolveRouteFromAddresses() async {
    var pickup = _kDefaultPickup;
    var drop = _kDefaultDrop;
    final pu = widget.pickupAddress.trim();
    final du = widget.destinationAddress.trim();
    try {
      if (!_isCurrentLocationPlaceholder(pu)) {
        final list = await locationFromAddress(pu);
        if (!mounted) return;
        if (list.isNotEmpty) {
          pickup = LatLng(list.first.latitude, list.first.longitude);
        }
      }
      if (du.isNotEmpty) {
        final list = await locationFromAddress(du);
        if (!mounted) return;
        if (list.isNotEmpty) {
          drop = LatLng(list.first.latitude, list.first.longitude);
        }
      }
      if (!mounted) return;
      setState(() {
        _pickupLatLng = pickup;
        _dropLatLng = drop;
      });
      await _fitRouteInView();
    } catch (_) {
      // Keep defaults; map still usable.
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _placeholderMapPan.dispose();
    super.dispose();
  }

  static const double _routeBoundsMargin = 0.62;

  Future<void> _fitRouteInView() async {
    final c = _mapController;
    if (c == null || !mounted) return;
    var sw = LatLng(
      math.min(_pickupLatLng.latitude, _dropLatLng.latitude),
      math.min(_pickupLatLng.longitude, _dropLatLng.longitude),
    );
    var ne = LatLng(
      math.max(_pickupLatLng.latitude, _dropLatLng.latitude),
      math.max(_pickupLatLng.longitude, _dropLatLng.longitude),
    );
    final latSpan = (ne.latitude - sw.latitude).abs();
    final lngSpan = (ne.longitude - sw.longitude).abs();
    final m = _routeBoundsMargin;
    sw = LatLng(sw.latitude - latSpan * m, sw.longitude - lngSpan * m);
    ne = LatLng(ne.latitude + latSpan * m, ne.longitude + lngSpan * m);
    final screenH = MediaQuery.sizeOf(context).height;
    const fraction = ZecarSheetMetrics.chooseRideSheetExtent;
    final sheetH = screenH * fraction;
    final topInset = MediaQuery.paddingOf(context).top + 48;
    final boundsPadding = (topInset + 72 + sheetH * 0.22).clamp(140.0, 280.0);
    await c.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: sw, northeast: ne),
        boundsPadding,
      ),
    );
  }

  void _onRecenter() {
    if (kGoogleMapsEnabled) {
      _fitRouteInView();
    } else {
      _placeholderMapPan.value = Matrix4.identity();
    }
  }

  RideOption get _selected => RideOptionsMock.recommended.firstWhere(
    (r) => r.id == _selectedRideId,
    orElse: () => RideOptionsMock.recommended.first,
  );

  void _openRideConfirmation() {
    final s = _selected;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ZecarRideConfirmationScreen(
          rideName: s.name,
          reserveLine: '${s.reserveVerb} ${s.name}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final mapChromeSurface = AppColors.lightSurface;
    final mapChromeOnSurface = AppColors.lightTextPrimary;
    final sheetShadow = colorScheme.shadow.withValues(alpha: 0.22);
    final h = MediaQuery.sizeOf(context).height;
    const sheetFraction = ZecarSheetMetrics.chooseRideSheetExtent;
    final fabBottom = h * sheetFraction + 12;
    final selected = _selected;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: kGoogleMapsEnabled
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _pickupLatLng,
                      zoom: 10,
                    ),
                    onMapCreated: (c) {
                      _mapController = c;
                      _fitRouteInView();
                    },
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                  )
                : ZecarMapPlaceholder(
                    transformationController: _placeholderMapPan,
                    isDark: isDark,
                  ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 0, 0),
                child: Material(
                  color: mapChromeSurface,
                  shape: const CircleBorder(),
                  elevation: 2,
                  shadowColor: sheetShadow,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.chevron_left,
                        size: 26,
                        color: mapChromeOnSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: fabBottom,
            child: Material(
              color: mapChromeSurface,
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: sheetShadow,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _onRecenter,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.my_location,
                    size: 22,
                    color: mapChromeOnSurface,
                  ),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: sheetFraction,
            minChildSize: sheetFraction,
            maxChildSize: sheetFraction,
            builder: (context, scrollController) {
              return Material(
                color: surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                elevation: 8,
                shadowColor: sheetShadow,
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: ZecarRideSheetColumn(
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isDark: isDark,
                        pickupAddress: widget.pickupAddress,
                        destinationAddress: widget.destinationAddress,
                        onEditAddresses: () => Navigator.of(context).maybePop(),
                        selectedRideId: _selectedRideId,
                        selected: selected,
                        onRideSelected: (id) {
                          setState(() => _selectedRideId = id);
                        },
                        onReserve: _openRideConfirmation,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
