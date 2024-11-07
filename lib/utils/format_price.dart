//가격을 여러군데서 쓰기 때문에 중복을 피하기 위해 유틸로 만들어둠
// lib/utils/utils.dart
String formatPrice(String price) {
  return price.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}

String formatDiscountedPriceToString(String price, double discountPercent) {
  // String price를 int로 변환
  final originalPrice = int.parse(price);

  // 할인된 가격 계산
  final discountedPrice = (originalPrice * (1 - discountPercent / 100)).round().toString();

  // 세 자리마다 쉼표 넣어 포맷팅 후 반환
  return formatPrice(discountedPrice);
}

int formatDiscountedPriceToInt(String price, double discountPercent) {
  // String price를 int로 변환
  final originalPrice = int.parse(price);

  // 세 자리마다 쉼표 넣어 포맷팅 후 반환
  return (originalPrice * (1 - discountPercent / 100)).round();
}
