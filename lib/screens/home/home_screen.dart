import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';
import 'package:zepay_app/models/services_model.dart';
import 'package:zepay_app/screens/search/search_screen.dart';
import 'package:zepay_app/screens/provided_services/service_router.dart';

part 'widgets/home_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Stack: Banner + AppBar + Search ──
          const _HomeHeader(),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Wallet Card ───────────────────────
                  _WalletCard(isDark: isDark),

                  // Gap between wallet and grid
                  const SizedBox(height: 36),
                  // ── Services Grid ─────────────────────
                  _ServicesGrid(isDark: isDark),

                  const SizedBox(height: 36),

                  // ── Promo Banner ──────────────────────
                  _PromoBanner(isDark: isDark),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Space for the overlapping search ba
        ],
      ),
    );
  }
}
