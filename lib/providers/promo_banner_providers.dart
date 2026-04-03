import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zepay_app/mock/promo_banner_mock_data.dart';
import 'package:zepay_app/models/promo_banner_model.dart';

/// Promo carousel items. Swap [PromoBannerMockData] for an API repository later.
final promoBannersProvider = Provider<List<PromoBannerModel>>((ref) {
  return PromoBannerMockData.banners;
});
