part of '../zesend_screen.dart';

class _AddressTypeAheadField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color textPrimary;
  final Color textSecondary;
  final Color iconColor;
  final Future<List<String>> Function(String query) suggestionsCallback;

  const _AddressTypeAheadField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.textPrimary,
    required this.textSecondary,
    required this.iconColor,
    required this.suggestionsCallback,
  });

  @override
  State<_AddressTypeAheadField> createState() => _AddressTypeAheadFieldState();
}

class _AddressTypeAheadFieldState extends State<_AddressTypeAheadField> {
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
          children: [
            Icon(Iconsax.location, size: 18, color: widget.iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: TypeAheadField<String>(
                controller: widget.controller,
                focusNode: widget.focusNode,
                debounceDuration: const Duration(milliseconds: 180),
                hideOnEmpty: true,
                suggestionsCallback: (pattern) async {
                  return widget.suggestionsCallback(pattern);
                },
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
                        contentPadding: const EdgeInsets.all(16),
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

class _VoucherCard extends StatelessWidget {
  final bool isDark;

  const _VoucherCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Iconsax.discount_shape,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2 vouchers for you',
                  style: AppTextStyles.bodySemiBold.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Apply and save more on delivery.',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.white),
        ],
      ),
    );
  }
}

class _PromoInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _PromoInfoCard({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: textSecondary),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Explore',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(
              'assets/images/parcelyellow.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
