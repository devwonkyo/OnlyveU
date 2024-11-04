import 'package:onlyveyou/models/product_model.dart';

extension ProductModelExtension on ProductModel {
  // 해당 유저 ID가 좋아요를 눌렀는지 확인하는 메서드
  bool isFavorite(String userId) {
    return favoriteList.contains(userId);
  }

  // 리뷰 개수를 반환하는 getter
  int get reviewCount => reviewList.length;

  // 할인가를 계산하여 반환하는 getter
  int get discountedPrice {
    try {
      int originalPrice = int.parse(price);
      return (originalPrice * (100 - discountPercent) / 100).round();
    } catch (e) {
      // 가격 형식이 올바르지 않거나 변환에 실패할 경우 0 반환
      return 0;
    }
  }
}