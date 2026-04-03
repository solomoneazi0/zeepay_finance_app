import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';
import 'package:zepay_app/screens/zesend_screen/delivery_details_screen.dart';
import 'package:zepay_app/services/address_autocomplete_service.dart';

part 'widgets/zesend_widgets.dart';

class ZeSendScreen extends StatefulWidget {
  const ZeSendScreen({super.key});

  @override
  State<ZeSendScreen> createState() => _ZeSendScreenState();
}

class _ZeSendScreenState extends State<ZeSendScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _dropoffFocusNode = FocusNode();
  final AddressAutocompleteService _addressService =
      AddressAutocompleteService();

  bool get _canAddPackageDetails {
    return _pickupController.text.trim().isNotEmpty &&
        _dropoffController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _pickupController.addListener(_onAddressInputChanged);
    _dropoffController.addListener(_onAddressInputChanged);
  }

  void _onAddressInputChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _pickupController.removeListener(_onAddressInputChanged);
    _dropoffController.removeListener(_onAddressInputChanged);
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocusNode.dispose();
    _dropoffFocusNode.dispose();
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
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _canAddPackageDetails
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ZeSendDeliveryDetailsScreen(
                              pickupAddress:
                                  _pickupController.text.trim(),
                              dropoffAddress:
                                  _dropoffController.text.trim(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add package details',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: surface,
            expandedHeight: 160,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Iconsax.arrow_left, color: textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: surface,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            isDark
                                ? 'assets/images/ZesendheaderDark.png'
                                : 'assets/images/zesendheader.png',
                            fit: BoxFit.cover,
                            alignment: const Alignment(0, -1),
                          ),
                          if (isDark)
                            Container(color: Colors.black.withOpacity(0.18)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          children: [
                            _AddressTypeAheadField(
                              label: 'Pickup at',
                              controller: _pickupController,
                              focusNode: _pickupFocusNode,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              iconColor: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                              suggestionsCallback:
                                  _addressService.fetchSuggestions,
                            ),
                            const SizedBox(height: 10),
                            Divider(color: border, height: 1),
                            const SizedBox(height: 10),
                            _AddressTypeAheadField(
                              label: 'Where to send?',
                              controller: _dropoffController,
                              focusNode: _dropoffFocusNode,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              iconColor: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                              suggestionsCallback:
                                  _addressService.fetchSuggestions,
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.06, end: 0),

                  const SizedBox(height: 16),
                  _VoucherCard(isDark: isDark)
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 350.ms)
                      .slideY(begin: 0.08, end: 0),

                  const SizedBox(height: 22),
                  Text(
                    'How ZeSend can help you',
                    style: AppTextStyles.h3.copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Send anything anytime with our flexible services.',
                    style: AppTextStyles.body.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: 14),

                  _PromoInfoCard(
                    title: 'Your package is guaranteed\nto arrive in 1 hour!',
                    subtitle: 'Get a voucher for late packages!',
                    isDark: isDark,
                  ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
                  const SizedBox(height: 12),
                  _PromoInfoCard(
                    title: "Let\'s Join ZeSend\'s\nRuang Belajar!",
                    subtitle: 'Connect with and learn from fellow sellers.',
                    isDark: isDark,
                  ).animate().fadeIn(delay: 260.ms, duration: 350.ms),
                  const SizedBox(height: 12),
                  _PromoInfoCard(
                    title: 'Big vehicles for big packages!',
                    subtitle: 'Move heavier items with ease.',
                    isDark: isDark,
                  ).animate().fadeIn(delay: 340.ms, duration: 350.ms),
                  const SizedBox(height: 12),
                  _PromoInfoCard(
                    title: 'Schedule your delivery',
                    subtitle: 'Pick a time that works for you.',
                    isDark: isDark,
                  ).animate().fadeIn(delay: 420.ms, duration: 350.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
