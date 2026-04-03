import 'package:flutter/foundation.dart';

/// UI grouping for lists/grids (e.g. Promo, Popular, Nearby).
@immutable
class FoodSectionModel {
  const FoodSectionModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

