import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zepay_app/config/google_maps_config.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';
import 'package:zepay_app/models/package_category.dart';
import 'package:zepay_app/screens/zesend_screen/widgets/delivery_details_widgets.dart';
import 'package:zepay_app/screens/zesend_screen/widgets/package_size_bottom_sheet.dart';

class ZeSendDeliveryDetailsScreen extends StatefulWidget {
  const ZeSendDeliveryDetailsScreen({
    super.key,
    required this.pickupAddress,
    this.dropoffAddress = '',
  });

  final String pickupAddress;
  final String dropoffAddress;

  @override
  State<ZeSendDeliveryDetailsScreen> createState() =>
      _ZeSendDeliveryDetailsScreenState();
}

class _ZeSendDeliveryDetailsScreenState
    extends State<ZeSendDeliveryDetailsScreen> {
  GoogleMapController? _mapController;
  LatLng _cameraTarget = const LatLng(38.8977, -77.0365);
  bool _mapLoading = true;
  String? _mapError;

  final _landmarkController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _othersDescriptionController = TextEditingController();

  String? _packageType;
  String? _othersDescriptionError;

  static const int _othersDescriptionWordCount = 10;

  int _wordCount(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  bool _validateForProceed() {
    if (_packageType == PackageCategory.kOthersId) {
      final n = _wordCount(_othersDescriptionController.text);
      if (n != _othersDescriptionWordCount) {
        setState(() {
          _othersDescriptionError = n == 0
              ? 'Please write exactly $_othersDescriptionWordCount words describing your package.'
              : 'Use exactly $_othersDescriptionWordCount words (you have $n).';
        });
        return false;
      }
    }
    setState(() => _othersDescriptionError = null);
    return true;
  }

  Future<void> _onProceed() async {
    if (!_validateForProceed()) return;

    final packageSizeId = await showPackageSizeBottomSheet(context);
    if (!mounted || packageSizeId == null) return;

    Navigator.of(context).pop(packageSizeId);
  }

  @override
  void initState() {
    super.initState();
    _resolvePickupLocation();
  }

  Future<void> _resolvePickupLocation() async {
    final query = widget.pickupAddress.trim();
    if (query.isEmpty) {
      setState(() {
        _mapLoading = false;
        _mapError = 'No pickup address';
      });
      return;
    }

    try {
      final locations = await locationFromAddress(query);
      if (!mounted) return;
      if (locations.isEmpty) {
        setState(() => _mapLoading = false);
        return;
      }
      final loc = locations.first;
      final latLng = LatLng(loc.latitude, loc.longitude);
      setState(() {
        _cameraTarget = latLng;
        _mapLoading = false;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
    } catch (_) {
      if (!mounted) return;
      setState(() => _mapLoading = false);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _landmarkController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _othersDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Delivery details',
          style: AppTextStyles.h3.copyWith(color: textPrimary),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _packageType == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Proceed',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_mapLoading)
                      ColoredBox(
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lightBorder,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (kGoogleMapsEnabled)
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _cameraTarget,
                          zoom: 15,
                        ),
                        onMapCreated: (c) {
                          _mapController = c;
                          c.animateCamera(
                            CameraUpdate.newLatLngZoom(_cameraTarget, 15),
                          );
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('pickup'),
                            position: _cameraTarget,
                            infoWindow: InfoWindow(
                              title: 'Pickup',
                              snippet: widget.pickupAddress,
                            ),
                          ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        onTap: (LatLng pos) {
                          setState(() => _cameraTarget = pos);
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLng(pos),
                          );
                        },
                      )
                    else
                      DeliveryMapPlaceholder(
                        isDark: isDark,
                        address: widget.pickupAddress,
                        latitude: _cameraTarget.latitude,
                        longitude: _cameraTarget.longitude,
                      ),
                    if (_mapError != null && !_mapLoading)
                      ColoredBox(
                        color: Colors.black54,
                        child: Center(
                          child: Text(
                            _mapError!,
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    if (kGoogleMapsEnabled && !_mapLoading)
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Text(
                                'Tap to move pin',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.bookmark, size: 18, color: textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Pickup',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          color: textPrimary,
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textPrimary,
                          side: BorderSide(color: border),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('Edit', style: AppTextStyles.captionMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.pickupAddress,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _landmarkController,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Any landmark near here? (optional)',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: textSecondary,
                      ),
                      prefixIcon: Icon(
                        Iconsax.flag,
                        size: 20,
                        color: textSecondary,
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Recipient details',
                  style: AppTextStyles.h4.copyWith(color: textPrimary),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    side: BorderSide(color: border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Use my details',
                    style: AppTextStyles.captionMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DeliveryLabeledField(
              label: "Recipient's name",
              requiredMark: true,
              child: TextField(
                controller: _nameController,
                style: AppTextStyles.body.copyWith(color: textPrimary),
                decoration: _inputDecoration(
                  hint: "Enter recipient's name...",
                  isDark: isDark,
                  bg: bg,
                  textSecondary: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            DeliveryLabeledField(
              label: 'Phone number',
              requiredMark: true,
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.body.copyWith(color: textPrimary),
                decoration: _inputDecoration(
                  hint: 'Enter phone number...',
                  isDark: isDark,
                  bg: bg,
                  textSecondary: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            DeliveryLabeledField(
              label: 'Email',
              requiredMark: true,
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.body.copyWith(color: textPrimary),
                decoration: _inputDecoration(
                  hint: 'Enter email address...',
                  isDark: isDark,
                  bg: bg,
                  textSecondary: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'What kind of package?',
                  style: AppTextStyles.h4.copyWith(color: textPrimary),
                ),
                Text(
                  ' *',
                  style: AppTextStyles.h4.copyWith(color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: PackageCategory.zesendDelivery.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.35,
              ),
              itemBuilder: (context, index) {
                final category = PackageCategory.zesendDelivery[index];
                return DeliveryPackageChip(
                  label: category.label,
                  icon: category.icon,
                  selected: _packageType == category.id,
                  isDark: isDark,
                  onTap: () => setState(() {
                    _packageType = category.id;
                    _othersDescriptionError = null;
                  }),
                );
              },
            ),
            if (_packageType == PackageCategory.kOthersId) ...[
              const SizedBox(height: 24),
              DeliveryLabeledField(
                label: 'Package description',
                requiredMark: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'In $_othersDescriptionWordCount words, describe what you are sending '
                      'so we can handle it correctly.',
                      style: AppTextStyles.caption.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _othersDescriptionController,
                      minLines: 2,
                      maxLines: 4,
                      style: AppTextStyles.body.copyWith(color: textPrimary),
                      onChanged: (_) {
                        setState(() => _othersDescriptionError = null);
                      },
                      decoration: _inputDecoration(
                        hint:
                            'Type your $_othersDescriptionWordCount-word description here…',
                        isDark: isDark,
                        bg: bg,
                        textSecondary: textSecondary,
                      ).copyWith(errorText: _othersDescriptionError),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_wordCount(_othersDescriptionController.text)} / $_othersDescriptionWordCount words',
                      style: AppTextStyles.small.copyWith(color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(
              height: _packageType == null
                  ? 24
                  : (_packageType == PackageCategory.kOthersId ? 100 : 80),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isDark,
    required Color bg,
    required Color textSecondary,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body.copyWith(color: textSecondary),
      filled: true,
      fillColor: isDark ? AppColors.darkCard : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
