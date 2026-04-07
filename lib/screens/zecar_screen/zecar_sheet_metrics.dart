/// Shared [DraggableScrollableSheet] sizing for ZeCar flows so the collapsed
/// sheet hugs content instead of leaving empty space below (viewport must match
/// intrinsic column height, not an oversized fraction).
class ZecarSheetMetrics {
  ZecarSheetMetrics._();

  /// Before the first layout measure, use a modest fraction (not ~0.72).
  static const double bootstrapExtent = 0.40;

  /// [ZecarTripPlanningScreen] “Your trip” sheet: fixed fraction of screen height.
  static const double yourTripSheetExtent = 1.2 / 3.0;

  /// [ZecarRideScreen] “Choose a ride” sheet: fixed fraction of screen height.
  static const double chooseRideSheetExtent = 2.3 / 3.0;

  static const double extentFloor = 0.28;

  /// Allow tall “choose a ride” lists; do not cap collapsed height at 0.60.
  static const double collapsedMaxExtent = 0.92;

  static const double measureBufferPx = 8;

  static const double extentEpsilon = 0.002;

  static double extentForMeasuredContentHeight(
    double contentHeight,
    double screenHeight,
  ) {
    if (screenHeight <= 0) return extentFloor;
    final raw = (contentHeight + measureBufferPx) / screenHeight;
    return raw.clamp(extentFloor, collapsedMaxExtent).toDouble();
  }

  static bool extentNearlyEqual(double? a, double b) {
    if (a == null) return false;
    return (a - b).abs() < extentEpsilon;
  }
}
