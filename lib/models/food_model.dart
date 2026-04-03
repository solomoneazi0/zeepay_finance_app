import 'package:flutter/foundation.dart';

@immutable
class FoodModel {
  const FoodModel({
    required this.id,
    required this.name,
    required this.image,
    required this.distance,
    required this.rating,
    required this.sectionId,
    required this.foodCategoryId,
    required this.isPromo,
  });

  final String id;
  final String name;

  /// Can be an asset path (e.g. `assets/images/foo.png`) or a network URL.
  final String image;

  /// Display string such as "0.41 km".
  final String distance;

  /// Rating value such as 4.8.
  final double rating;

  /// Used for UI grouping (Promo/Popular/Nearby).
  final String sectionId;

  /// Used for ZeFood browsing (Breakfast/Dessert/Pasta/etc).
  final String foodCategoryId;
  final bool isPromo;
}

