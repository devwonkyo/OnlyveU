//가격을 여러군데서 쓰기 때문에 중복을 피하기 위해 유틸로 만들어둠
// lib/utils/utils.dart
import 'package:onlyveyou/models/order_model.dart';
import 'package:intl/intl.dart';
String formatPrice(String price) {
    if (price is int) {
    // 정수를 3자리마다 콤마로 구분하여 문자열로 반환
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
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

String intformatPrice(dynamic price) {
  if (price is int) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  } else if (price is String) {
    return price.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
  throw ArgumentError('formatPrice: price must be int or String');
}


Map<String, List<OrderModel>> groupOrdersByDate(List<OrderModel> orders) {
  final Map<String, List<OrderModel>> groupedOrders = {};

  for (var order in orders) {
    final date = DateFormat('yyyy-MM-dd').format(order.createdAt); // 날짜만 추출
    if (groupedOrders[date] == null) {
      groupedOrders[date] = [];
    }
    groupedOrders[date]!.add(order);
  }

  return groupedOrders;
}