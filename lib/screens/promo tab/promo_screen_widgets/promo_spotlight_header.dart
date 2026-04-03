import 'package:flutter/material.dart';
import 'package:zepay_app/constants/app_text_styles.dart';

/// Headline above the horizontal promo banner carousel.
class PromoSpotlightHeader extends StatelessWidget {
  const PromoSpotlightHeader({
    super.key,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(
          "Don't miss these promos!",
          style: AppTextStyles.h3.copyWith(color: textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Save more on every order — swap placeholders for your art.',
          style: AppTextStyles.body.copyWith(color: textSecondary),
        ),
      ],
    );
  }
}
