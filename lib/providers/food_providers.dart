import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zepay_app/mock/food_mock_data.dart';
import 'package:zepay_app/models/food_category_model.dart';
import 'package:zepay_app/models/food_model.dart';
import 'package:zepay_app/models/food_section_model.dart';

/// Base provider for all foods.
///
/// Today this reads from mock data; later swap the implementation to a repository
/// that fetches from your API without changing UI code.
final foodsProvider = Provider<List<FoodModel>>((ref) {
  return FoodMockData.foods;
});

/// UI sections provider (helps resolve the "Promo" section id).
final foodSectionsProvider = Provider<List<FoodSectionModel>>((ref) {
  return FoodMockData.sections;
});

/// Food categories provider (Breakfast, Dessert, Pasta, etc).
final foodCategoriesProvider = Provider<List<FoodCategoryModel>>((ref) {
  return FoodMockData.foodCategories;
});

final promoSectionIdProvider = Provider<String>((ref) {
  final sections = ref.watch(foodSectionsProvider);
  for (final c in sections) {
    if (c.name.toLowerCase() == 'promo') return c.id;
  }
  return 'promo';
});

/// Filtered provider for promo foods.
///
/// Rule:
/// - `isPromo == true`
/// - OR `sectionId == promoSectionId`
final promoFoodsProvider = Provider<List<FoodModel>>((ref) {
  final foods = ref.watch(foodsProvider);
  final promoSectionId = ref.watch(promoSectionIdProvider);

  return foods
      .where((f) => f.sectionId == promoSectionId)
      .toList(growable: false);
});
