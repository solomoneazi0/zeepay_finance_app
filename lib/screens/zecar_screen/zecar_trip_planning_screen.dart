import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zepay_app/config/google_maps_config.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';
import 'package:zepay_app/models/ride_option_model.dart';
import 'package:zepay_app/screens/zecar_screen/widgets/zecar_map_placeholder.dart';
import 'package:zepay_app/screens/zecar_screen/zecar_ride_confirmation_screen.dart';
import 'package:zepay_app/screens/zecar_screen/zecar_ride_sheet_widgets.dart';
import 'package:zepay_app/screens/zecar_screen/zecar_sheet_metrics.dart';
import 'package:zepay_app/services/address_autocomplete_service.dart';

enum _ZecarFlowStep { addresses, chooseRide }

/// Map + bottom sheet: “Your trip” then “Choose a ride” on the same route (no
/// full-screen push), so the map is not recreated.
class ZecarTripPlanningScreen extends StatefulWidget {
  const ZecarTripPlanningScreen({super.key});

  @override
  State<ZecarTripPlanningScreen> createState() =>
      _ZecarTripPlanningScreenState();
}

class _ZecarTripPlanningScreenState extends State<ZecarTripPlanningScreen> {
  static const String _defaultPickupLabel = 'Current location';
  static const LatLng _kMapTarget = LatLng(-6.1944, 106.8229);
  static const LatLng _kDefaultDrop = LatLng(-6.2250, 106.8010);
  static const double _routeBoundsMargin = 0.62;

  _ZecarFlowStep _flowStep = _ZecarFlowStep.addresses;
  String _ridePickupAddress = '';
  String _rideDestinationAddress = '';
  late LatLng _pickupLatLng;
  late LatLng _dropLatLng;
  late String _selectedRideId;

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _dropoffFocusNode = FocusNode();
  final AddressAutocompleteService _addressService =
      AddressAutocompleteService();

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final TransformationController _placeholderMapPan =
      TransformationController();

  GoogleMapController? _mapController;

  /// [DraggableScrollableSheet] inner scroll; used to clear offset when swapping panels.
  ScrollController? _innerSheetScroll;

  bool get _canContinue => _dropoffController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _pickupLatLng = _kMapTarget;
    _dropLatLng = _kDefaultDrop;
    _selectedRideId = RideOptionsMock.recommended.first.id;
    _pickupController.addListener(_onFieldsChanged);
    _dropoffController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _pickupController.removeListener(_onFieldsChanged);
    _dropoffController.removeListener(_onFieldsChanged);
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocusNode.dispose();
    _dropoffFocusNode.dispose();
    _sheetController.dispose();
    _placeholderMapPan.dispose();
    super.dispose();
  }

  Future<void> _centerMap() async {
    final c = _mapController;
    if (c == null || !mounted) return;
    await c.animateCamera(CameraUpdate.newLatLngZoom(_kMapTarget, 10));
  }

  void _onRecenter() {
    if (kGoogleMapsEnabled) {
      if (_flowStep == _ZecarFlowStep.chooseRide) {
        _fitRouteInView();
      } else {
        _centerMap();
      }
    } else {
      _placeholderMapPan.value = Matrix4.identity();
    }
  }

  static bool _isCurrentLocationPlaceholder(String s) {
    final t = s.trim().toLowerCase();
    return t.isEmpty || t == 'current location';
  }

  Future<void> _resolveRouteFromAddresses() async {
    var pickup = _kMapTarget;
    var drop = _kDefaultDrop;
    final pu = _ridePickupAddress.trim();
    final du = _rideDestinationAddress.trim();
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
      // Keep last camera; map still usable.
    }
  }

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

  void _continueToChooseRide() {
    if (!_canContinue) return;
    final pu = _pickupController.text.trim().isEmpty
        ? _defaultPickupLabel
        : _pickupController.text.trim();
    final du = _dropoffController.text.trim();
    setState(() {
      _flowStep = _ZecarFlowStep.chooseRide;
      _ridePickupAddress = pu;
      _rideDestinationAddress = du;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_sheetController.isAttached) {
        _sheetController.jumpTo(ZecarSheetMetrics.chooseRideSheetExtent);
      }
      _innerSheetScroll?.jumpTo(0);
      _resolveRouteFromAddresses();
    });
  }

  void _backToAddressStep() {
    setState(() => _flowStep = _ZecarFlowStep.addresses);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_sheetController.isAttached) {
        _sheetController.jumpTo(ZecarSheetMetrics.yourTripSheetExtent);
      }
      _innerSheetScroll?.jumpTo(0);
      if (kGoogleMapsEnabled) {
        _centerMap();
      }
    });
  }

  RideOption get _selectedRide => RideOptionsMock.recommended.firstWhere(
    (r) => r.id == _selectedRideId,
    orElse: () => RideOptionsMock.recommended.first,
  );

  void _openRideConfirmation() {
    final s = _selectedRide;
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
    final iconColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final h = MediaQuery.sizeOf(context).height;
    final sheetFraction = _flowStep == _ZecarFlowStep.chooseRide
        ? ZecarSheetMetrics.chooseRideSheetExtent
        : ZecarSheetMetrics.yourTripSheetExtent;
    final fabBottom = h * sheetFraction + 12;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: kGoogleMapsEnabled
                ? GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _kMapTarget,
                      zoom: 10,
                    ),
                    onMapCreated: (c) {
                      _mapController = c;
                      _centerMap();
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
                    onTap: () {
                      if (_flowStep == _ZecarFlowStep.chooseRide) {
                        _backToAddressStep();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
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
            initialChildSize: ZecarSheetMetrics.yourTripSheetExtent,
            minChildSize: ZecarSheetMetrics.yourTripSheetExtent,
            maxChildSize: ZecarSheetMetrics.collapsedMaxExtent,
            builder: (context, scrollController) {
              _innerSheetScroll = scrollController;
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
                      child: ClipRect(
                        clipBehavior: Clip.hardEdge,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          layoutBuilder:
                              (Widget? currentChild, List<Widget> previous) {
                                return Stack(
                                  alignment: Alignment.topCenter,
                                  clipBehavior: Clip.hardEdge,
                                  children: <Widget>[
                                    ...previous,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                          transitionBuilder: (child, animation) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                              reverseCurve: Curves.easeInCubic,
                            );
                            return FadeTransition(
                              opacity: curved,
                              child: child,
                            );
                          },
                          child: _flowStep == _ZecarFlowStep.addresses
                              ? KeyedSubtree(
                                  key: const ValueKey<String>(
                                    'zecar_sheet_addresses',
                                  ),
                                  child: _TripPlanSheetColumn(
                                    border: border,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    iconColor: iconColor,
                                    pickupController: _pickupController,
                                    dropoffController: _dropoffController,
                                    pickupFocusNode: _pickupFocusNode,
                                    dropoffFocusNode: _dropoffFocusNode,
                                    suggestionsCallback:
                                        _addressService.fetchSuggestions,
                                    canContinue: _canContinue,
                                    onContinue: _continueToChooseRide,
                                  ),
                                )
                              : KeyedSubtree(
                                  key: const ValueKey<String>(
                                    'zecar_sheet_choose_ride',
                                  ),
                                child: ZecarRideSheetColumn(
                                  border: border,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  isDark: isDark,
                                  pickupAddress: _ridePickupAddress,
                                  destinationAddress: _rideDestinationAddress,
                                  onEditAddresses: _backToAddressStep,
                                  selectedRideId: _selectedRideId,
                                  selected: _selectedRide,
                                  onRideSelected: (id) {
                                    setState(() => _selectedRideId = id);
                                  },
                                  onReserve: _openRideConfirmation,
                                ),
                                ),
                        ),
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

class _TripPlanSheetColumn extends StatelessWidget {
  const _TripPlanSheetColumn({
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.iconColor,
    required this.pickupController,
    required this.dropoffController,
    required this.pickupFocusNode,
    required this.dropoffFocusNode,
    required this.suggestionsCallback,
    required this.canContinue,
    required this.onContinue,
  });

  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color iconColor;
  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final FocusNode pickupFocusNode;
  final FocusNode dropoffFocusNode;
  final Future<List<String>> Function(String query) suggestionsCallback;
  final bool canContinue;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Your trip',
            style: AppTextStyles.h3.copyWith(color: textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: border),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Pickup & destination',
            style: AppTextStyles.caption.copyWith(
              color: textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? AppColors.darkCard
                  : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ZecarLocationTypeAhead(
                  label: 'Current location',
                  controller: pickupController,
                  focusNode: pickupFocusNode,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  iconColor: iconColor,
                  suggestionsCallback: suggestionsCallback,
                ),
                const SizedBox(height: 8),
                Divider(color: border, height: 1),
                const SizedBox(height: 8),
                _ZecarLocationTypeAhead(
                  label: 'Where to?',
                  controller: dropoffController,
                  focusNode: dropoffFocusNode,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  iconColor: iconColor,
                  suggestionsCallback: suggestionsCallback,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomSafe),
          child: FilledButton(
            onPressed: canContinue ? onContinue : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor: border,
              disabledForegroundColor: textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
            ),
            child: Text(
              'Continue',
              style: AppTextStyles.button.copyWith(
                color: canContinue
                    ? theme.colorScheme.onPrimary
                    : textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ZecarLocationTypeAhead extends StatefulWidget {
  const _ZecarLocationTypeAhead({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.textPrimary,
    required this.textSecondary,
    required this.iconColor,
    required this.suggestionsCallback,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color textPrimary;
  final Color textSecondary;
  final Color iconColor;
  final Future<List<String>> Function(String query) suggestionsCallback;

  @override
  State<_ZecarLocationTypeAhead> createState() =>
      _ZecarLocationTypeAheadState();
}

class _ZecarLocationTypeAheadState extends State<_ZecarLocationTypeAhead> {
  bool _confirmed = false;
  String _lastConfirmedText = '';
  bool _ignoreNextChange = false;

  void _confirmSelection(String value) {
    _ignoreNextChange = true;
    widget.controller.text = value;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
    setState(() {
      _confirmed = true;
      _lastConfirmedText = value;
    });
  }

  void _onChanged(String value) {
    if (_ignoreNextChange) {
      _ignoreNextChange = false;
      return;
    }
    if (_confirmed && value.trim() != _lastConfirmedText.trim()) {
      setState(() => _confirmed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final hasInput = value.text.trim().isNotEmpty;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Icon(Iconsax.location, size: 18, color: widget.iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TypeAheadField<String>(
                controller: widget.controller,
                focusNode: widget.focusNode,
                debounceDuration: const Duration(milliseconds: 180),
                hideOnEmpty: true,
                suggestionsCallback: widget.suggestionsCallback,
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Iconsax.location,
                      size: 16,
                      color: widget.textSecondary,
                    ),
                    title: Text(
                      suggestion,
                      style: AppTextStyles.body.copyWith(
                        color: widget.textPrimary,
                      ),
                    ),
                  );
                },
                onSelected: (value) {
                  _confirmSelection(value);
                  FocusScope.of(context).unfocus();
                },
                builder: (context, localController, localFocusNode) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasInput
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 1.4,
                      ),
                    ),
                    child: TextField(
                      controller: localController,
                      focusNode: localFocusNode,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      onChanged: _onChanged,
                      style: AppTextStyles.body.copyWith(
                        color: widget.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.label,
                        hintStyle: AppTextStyles.body.copyWith(
                          color: widget.textSecondary,
                        ),
                        suffixIcon: _confirmed && hasInput
                            ? const Icon(
                                Iconsax.tick_circle,
                                size: 20,
                                color: AppColors.primary,
                              )
                            : null,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  );
                },
                decorationBuilder: (context, child) {
                  return Material(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 4,
                    child: child,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
