import 'package:flutter/foundation.dart';

/// One item in the horizontal promo banner carousel.
@immutable
class PromoBannerModel {
  const PromoBannerModel({
    required this.id,
    required this.image,
    this.title,
    this.subtitle,
    this.showNewBadge = true,
  });

  final String id;

  /// Asset path (e.g. `assets/images/promo1.png`) or `https://...` URL.
  final String image;

  /// Shown when [image] is empty (placeholder state) or as overlay text if you add it in UI.
  final String? title;

  final String? subtitle;

  final bool showNewBadge;
}
