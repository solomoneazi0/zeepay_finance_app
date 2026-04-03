import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/providers/food_providers.dart';
import 'package:zepay_app/providers/promo_banner_providers.dart';
import 'package:zepay_app/screens/promo%20tab/promo_screen_widgets/food_grid_item.dart';
import 'package:zepay_app/screens/promo%20tab/promo_screen_widgets/promo_food_card_sizes.dart';
import 'package:zepay_app/screens/promo%20tab/promo_screen_widgets/promo_header.dart';
import 'package:zepay_app/screens/promo%20tab/promo_screen_widgets/promo_image_carousel.dart';
import 'package:zepay_app/screens/promo%20tab/promo_screen_widgets/promo_spotlight_header.dart';

class PromoScreen extends ConsumerWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final promoFoods = ref.watch(promoFoodsProvider);
    final promoBanners = ref.watch(promoBannersProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: PromoHeader(
                  title: 'Promos',
                  subtitle: 'Steal deals on your radar',
                  onSeeAll: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('See all promos')),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: kPromoFoodCardHeight + kPromoFoodRowListVerticalPadding,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  itemCount: promoFoods.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final food = promoFoods[index];
                    return SizedBox(
                      width: kPromoFoodCardWidth,
                      height: kPromoFoodCardHeight,
                      child: FoodGridItem(
                        food: food,
                        isDark: isDark,
                        surface: surface,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(food.name)));
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: PromoSpotlightHeader(
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: PromoImageCarousel(
                isDark: isDark,
                banners: promoBanners,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
