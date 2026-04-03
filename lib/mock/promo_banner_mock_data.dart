import 'package:zepay_app/models/promo_banner_model.dart';

class PromoBannerMockData {
  PromoBannerMockData._();

  /// Replace/add paths under `assets/images/` and declare them in [pubspec.yaml].
  static const List<PromoBannerModel> banners = [
    PromoBannerModel(
      id: 'banner_1',
      image: 'assets/images/promobanner1.png',
      title: 'Weekend deal',
      showNewBadge: true,
    ),
    PromoBannerModel(
      id: 'banner_2',
      image: 'assets/images/bannerimage2.png',
      title: 'Add asset path',
      subtitle: 'Drop file in assets/images/',
      showNewBadge: true,
    ),
    PromoBannerModel(
      id: 'banner_3',
      image: '',
      title: 'Coming soon',
      showNewBadge: false,
    ),
  ];
}
