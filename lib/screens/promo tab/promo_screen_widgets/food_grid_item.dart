import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';
import 'package:zepay_app/models/food_model.dart';

class FoodGridItem extends StatelessWidget {
  const FoodGridItem({
    super.key,
    required this.food,
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  final FoodModel food;
  final bool isDark;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Material(
      color: surface,
      elevation: 1.2,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: _FoodImage(image: food.image, isDark: isDark),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              food.foodCategoryId.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySemiBold.copyWith(
                                color: textPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            food.distance,
                            style: AppTextStyles.small.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        food.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySemiBold.copyWith(
                          color: textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _RatingBadge(rating: food.rating),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodImage extends StatelessWidget {
  const _FoodImage({required this.image, required this.isDark});

  final String image;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (image.trim().isEmpty) return _ImagePlaceholder(isDark: isDark);

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return _NetworkImageWithPlaceholder(url: image, isDark: isDark);
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _ImagePlaceholder(isDark: isDark),
    );
  }
}

class _NetworkImageWithPlaceholder extends StatelessWidget {
  const _NetworkImageWithPlaceholder({required this.url, required this.isDark});

  final String url;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => _ImagePlaceholder(isDark: isDark),
      errorWidget: (_, __, ___) => _ImagePlaceholder(isDark: isDark),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? AppColors.darkCard : const Color(0xFFEAEAEA);
    final iconColor = isDark ? AppColors.darkTextSecondary : Colors.black45;
    return ColoredBox(
      color: base,
      child: Center(child: Icon(Iconsax.image, color: iconColor, size: 28)),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.captionMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
