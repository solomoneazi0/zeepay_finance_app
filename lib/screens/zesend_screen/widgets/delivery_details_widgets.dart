import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zepay_app/constants/app_colors.dart';
import 'package:zepay_app/constants/app_text_styles.dart';

/// Shown when maps are disabled so we never mount [GoogleMap] without valid
/// native API keys (which would crash iOS).
class DeliveryMapPlaceholder extends StatelessWidget {
  const DeliveryMapPlaceholder({
    super.key,
    required this.isDark,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final bool isDark;
  final String address;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final onGreen = Colors.white.withOpacity(0.92);
    final onGreenMuted = Colors.white.withOpacity(0.75);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF1B4332),
                  Color(0xFF2D6A4F),
                  AppColors.primaryDark,
                ]
              : [
                  AppColors.primaryLight,
                  AppColors.primary.withOpacity(0.85),
                  AppColors.primary,
                ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DeliveryMapGridPainter(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.map_1, size: 44, color: onGreen),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.location, size: 30, color: onGreen),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    address.isEmpty ? 'Pickup location' : address,
                    style: AppTextStyles.caption.copyWith(
                      color: onGreen,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                  style: AppTextStyles.small.copyWith(color: onGreenMuted),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    'Map preview · add API key for live map',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryMapGridPainter extends CustomPainter {
  _DeliveryMapGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DeliveryLabeledField extends StatelessWidget {
  const DeliveryLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.requiredMark = false,
  });

  final String label;
  final Widget child;
  final bool requiredMark;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
            ),
            if (requiredMark)
              Text(
                ' *',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class DeliveryPackageChip extends StatelessWidget {
  const DeliveryPackageChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = selected
        ? AppColors.primary
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);
    final iconColor = selected
        ? AppColors.primary
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const iconBlockWidth = 20.0 + 6.0;
              final textMaxWidth = (constraints.maxWidth - iconBlockWidth)
                  .clamp(0.0, double.infinity);
              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: iconColor),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: textMaxWidth),
                      child: Text(
                        label,
                        style: AppTextStyles.captionMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
