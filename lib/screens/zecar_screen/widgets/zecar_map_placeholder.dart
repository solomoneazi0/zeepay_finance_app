import 'package:flutter/material.dart';
import 'package:zepay_app/constants/app_colors.dart';

/// Map stand-in when [kGoogleMapsEnabled] is false: zoomed-out “blocks & roads”.
/// For real roads and labels, enable Maps API keys and [kGoogleMapsEnabled].
class ZecarMapPlaceholder extends StatelessWidget {
  const ZecarMapPlaceholder({
    super.key,
    required this.transformationController,
    required this.isDark,
  });

  final TransformationController transformationController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;

    return ColoredBox(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: InteractiveViewer(
        transformationController: transformationController,
        panEnabled: true,
        scaleEnabled: true,
        boundaryMargin: const EdgeInsets.all(180),
        minScale: 0.4,
        maxScale: 3.5,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: w,
          height: h,
          child: CustomPaint(painter: _CityBlockMapPainter(isDark: isDark)),
        ),
      ),
    );
  }
}

/// Low-detail city: wide road corridors + building masses (reads as “zoomed out”).
class _CityBlockMapPainter extends CustomPainter {
  _CityBlockMapPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final road = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final roadMajor = isDark
        ? Color.lerp(AppColors.darkBorder, AppColors.darkTextSecondary, 0.22)!
        : Color.lerp(
            AppColors.lightBorder,
            AppColors.lightTextSecondary,
            0.45,
          )!;
    final park = isDark
        ? Color.lerp(AppColors.darkSurface, AppColors.primary, 0.22)!
        : AppColors.primaryLight;
    final water = isDark
        ? Color.lerp(AppColors.darkSurface, AppColors.info, 0.32)!
        : AppColors.zeRideBg;

    final b0 = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final b1 = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    const roadW = 5.5;
    const majorW = 8.0;

    // Major corridors — spaced out like a neighborhood overview
    final cx = <double>[
      size.width * 0.08,
      size.width * 0.38,
      size.width * 0.68,
      size.width * 0.94,
    ];
    final cy = <double>[
      size.height * 0.14,
      size.height * 0.42,
      size.height * 0.70,
      size.height * 0.93,
    ];

    void fillBlock(Rect r, Color c) {
      if (r.width < 8 || r.height < 8) return;
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        Paint()..color = c,
      );
    }

    // Building slabs between roads
    final xStops = <double>[0, ...cx, size.width];
    final yStops = <double>[0, ...cy, size.height];
    for (var yi = 0; yi < yStops.length - 1; yi++) {
      for (var xi = 0; xi < xStops.length - 1; xi++) {
        final x0 = xStops[xi] + (xi > 0 ? majorW / 2 : 0);
        final x1 = xStops[xi + 1] - (xi < xStops.length - 2 ? majorW / 2 : 0);
        final y0 = yStops[yi] + (yi > 0 ? majorW / 2 : 0);
        final y1 = yStops[yi + 1] - (yi < yStops.length - 2 ? majorW / 2 : 0);
        final cell = Rect.fromLTRB(x0, y0, x1, y1);
        if (cell.width > 12 && cell.height > 12) {
          fillBlock(cell.deflate(3), (xi + yi).isEven ? b0 : b1);
        }
      }
    }

    // Parks / water (reads as non-building map features)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.52,
          size.height * 0.08,
          size.width * 0.38,
          size.height * 0.16,
        ),
        const Radius.circular(14),
      ),
      Paint()..color = park,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.04,
          size.height * 0.55,
          size.width * 0.28,
          size.height * 0.22,
        ),
        const Radius.circular(12),
      ),
      Paint()..color = water,
    );

    // Horizontal roads
    for (final y in cy) {
      canvas.drawRect(
        Rect.fromLTWH(0, y - roadW / 2, size.width, roadW),
        Paint()..color = road,
      );
    }
    // Vertical roads
    for (final x in cx) {
      final w = x == cx[1] || x == cx[2] ? majorW : roadW;
      final paint = Paint()
        ..color = x == cx[1] || x == cx[2] ? roadMajor : road;
      canvas.drawRect(Rect.fromLTWH(x - w / 2, 0, w, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CityBlockMapPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
