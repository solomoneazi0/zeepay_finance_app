import 'package:zepay_app/models/food_category_model.dart';
import 'package:zepay_app/models/food_model.dart';
import 'package:zepay_app/models/food_section_model.dart';

/// Mock dataset for ZeFood (and promo screens) while API is not ready.
class FoodMockData {
  FoodMockData._();

  // --- UI sections (grouping) ---
  static const FoodSectionModel promoSection = FoodSectionModel(
    id: 'promo',
    name: 'Promo',
  );
  static const FoodSectionModel popularSection = FoodSectionModel(
    id: 'popular',
    name: 'Popular',
  );
  static const FoodSectionModel nearbySection = FoodSectionModel(
    id: 'nearby',
    name: 'Nearby',
  );

  static const List<FoodSectionModel> sections = [
    promoSection,
    popularSection,
    nearbySection,
  ];

  // --- Food categories (what the food is) ---
  static const FoodCategoryModel breakfastCategory = FoodCategoryModel(
    id: 'breakfast',
    name: 'Breakfast',
  );
  static const FoodCategoryModel dessertCategory = FoodCategoryModel(
    id: 'dessert',
    name: 'Dessert',
  );
  static const FoodCategoryModel pastaCategory = FoodCategoryModel(
    id: 'pasta',
    name: 'Pasta',
  );
  static const FoodCategoryModel africanCategory = FoodCategoryModel(
    id: 'african',
    name: 'African',
  );

  static const List<FoodCategoryModel> foodCategories = [
    breakfastCategory,
    dessertCategory,
    pastaCategory,
    africanCategory,
  ];

  /// Asset images are optional. If you don't have them yet, keep `image` empty
  /// and the UI will show a clean placeholder.
  static const List<FoodModel> foods = [
    FoodModel(
      id: 'f1',
      name: 'Soez Deliz, Bintaro Tangsel',
      image: 'assets/images/soes_deliz.png',
      distance: '0.41 km',
      rating: 4.8,
      sectionId: 'promo',
      foodCategoryId: 'dessert',
      isPromo: true,
    ),
    FoodModel(
      id: 'f2',
      name: 'Pempek Ny. Kamto, Bintaro',
      image: 'assets/images/pempek.png',
      distance: '0.53 km',
      rating: 4.8,
      sectionId: 'promo',
      foodCategoryId: 'african',
      isPromo: true,
    ),
    FoodModel(
      id: 'f3',
      name: 'Ayam Kalasan',
      image: 'assets/images/ayam_kalasan.jpg',
      distance: '1.53 km',
      rating: 4.8,
      sectionId: 'promo',
      foodCategoryId: 'breakfast',
      isPromo: true,
    ),
    FoodModel(
      id: 'f4',
      name: 'Green Bowl Salad',
      image: '',
      distance: '0.77 km',
      rating: 4.7,
      sectionId: 'nearby',
      foodCategoryId: 'breakfast',
      isPromo: true,
    ),
    FoodModel(
      id: 'f5',
      name: 'Spicy Ramen House',
      image: '',
      distance: '2.11 km',
      rating: 4.6,
      sectionId: 'popular',
      foodCategoryId: 'pasta',
      isPromo: false,
    ),
    FoodModel(
      id: 'f6',
      name: 'Classic Burger Joint',
      image: '',
      distance: '3.03 km',
      rating: 4.5,
      sectionId: 'popular',
      foodCategoryId: 'pasta',
      isPromo: false,
    ),
  ];
}
