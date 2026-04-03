import 'package:flutter/material.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';

class PromoHeader extends StatelessWidget {
  const PromoHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSeeAll,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h2.copyWith(color: textPrimary)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                subtitle,
                style: AppTextStyles.body.copyWith(color: textSecondary),
              ),
            ),
            OutlinedButton(
              onPressed: onSeeAll,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: border),
                foregroundColor: textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text('See All', style: AppTextStyles.captionMedium),
            ),
          ],
        ),
      ],
    );
  }
}
