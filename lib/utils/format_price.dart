//가격을 여러군데서 쓰기 때문에 중복을 피하기 위해 유틸로 만들어둠
// lib/utils/utils.dart
String formatPrice(String price) {
  return price.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}
