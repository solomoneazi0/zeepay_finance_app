import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';
import 'package:zepay_app/models/promo_banner_model.dart';

/// Horizontal promo banners driven by [PromoBannerModel] list (from provider / API).
class PromoImageCarousel extends StatelessWidget {
  const PromoImageCarousel({
    super.key,
    required this.isDark,
    required this.banners,
  });

  final bool isDark;
  final List<PromoBannerModel> banners;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final slideWidth = (width - 16 * 2 - 12).clamp(260.0, width * 0.88);
    const aspect = 16 / 9;
    final slideHeight = slideWidth / aspect;

    if (banners.isEmpty) {
      return SizedBox(
        height: slideHeight + 24,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: slideWidth,
              height: slideHeight,
              child: _PromoBannerSlide(
                isDark: isDark,
                banner: const PromoBannerModel(
                  id: 'empty',
                  image: '',
                  title: 'No promos yet',
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: slideHeight + 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        primary: false,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        itemCount: banners.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: slideWidth,
            height: slideHeight,
            child: _PromoBannerSlide(isDark: isDark, banner: banners[index]),
          );
        },
      ),
    );
  }
}

class _PromoBannerSlide extends StatelessWidget {
  const _PromoBannerSlide({required this.isDark, required this.banner});

  final bool isDark;
  final PromoBannerModel banner;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _BannerImageLayer(banner: banner, isDark: isDark),
          if (banner.showNewBadge)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'BARU!',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BannerImageLayer extends StatelessWidget {
  const _BannerImageLayer({required this.banner, required this.isDark});

  final PromoBannerModel banner;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final image = banner.image.trim();
    if (image.isEmpty) {
      return _PromoGradientPlaceholder(isDark: isDark, banner: banner);
    }
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            _PromoGradientPlaceholder(isDark: isDark, banner: banner),
        errorWidget: (_, __, ___) =>
            _PromoGradientPlaceholder(isDark: isDark, banner: banner),
      );
    }
    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          _PromoGradientPlaceholder(isDark: isDark, banner: banner),
    );
  }
}

class _PromoGradientPlaceholder extends StatelessWidget {
  const _PromoGradientPlaceholder({required this.isDark, required this.banner});

  final bool isDark;
  final PromoBannerModel banner;

  @override
  Widget build(BuildContext context) {
    final c1 = (isDark ? AppColors.primaryDark : AppColors.primary).withValues(
      alpha: isDark ? 0.45 : 0.35,
    );
    final c2 = (isDark ? AppColors.darkCard : AppColors.primaryLight)
        .withValues(alpha: isDark ? 0.95 : 1);
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.image,
                size: 40,
                color: isDark ? Colors.white54 : Colors.black38,
              ),
              const SizedBox(height: 8),
              if (banner.title != null)
                Text(
                  banner.title!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySemiBold.copyWith(
                    color: textPrimary,
                  ),
                ),
              if (banner.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  banner.subtitle!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(color: textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
