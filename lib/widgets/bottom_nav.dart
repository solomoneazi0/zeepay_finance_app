import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

// ── Bottom Nav Provider ────────────────────────────────────
final bottomNavProvider = StateProvider<int>((ref) => 0);

// ── Bottom Nav Bar ─────────────────────────────────────────
class ZevoaBottomNav extends ConsumerWidget {
  const ZevoaBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false, // only protect bottom
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Iconsax.home,
                activeIcon: Iconsax.home_15,
                label: 'Home',
                index: 0,
                currentIndex: currentIndex,
                isDark: isDark,
                onTap: () => ref.read(bottomNavProvider.notifier).state = 0,
              ),
              _NavItem(
                icon: Iconsax.discount_shape,
                activeIcon: Iconsax.discount_shape5,
                label: 'Promo',
                index: 1,
                currentIndex: currentIndex,
                isDark: isDark,
                onTap: () => ref.read(bottomNavProvider.notifier).state = 1,
              ),
              _NavItem(
                icon: Iconsax.activity,
                activeIcon: Iconsax.activity5,
                label: 'Activity',
                index: 2,
                currentIndex: currentIndex,
                isDark: isDark,
                onTap: () => ref.read(bottomNavProvider.notifier).state = 2,
              ),
              _NavItem(
                icon: Iconsax.message,
                activeIcon: Iconsax.message5,
                label: 'Message',
                index: 3,
                currentIndex: currentIndex,
                isDark: isDark,
                onTap: () => ref.read(bottomNavProvider.notifier).state = 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav Item ───────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 24,
                color: isActive
                    ? AppColors.primary
                    : isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),

            const SizedBox(height: 4),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.small.copyWith(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.primary
                    : isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
