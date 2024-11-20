import 'package:onlyveyou/models/order_model.dart';

const Map<OrderStatus, String> orderStatusToKorean = {
  OrderStatus.pending: "주문 대기",
  OrderStatus.confirmed: "주문 확인",
  OrderStatus.canceled: "주문 취소",
  OrderStatus.completed: "주문 완료",
  OrderStatus.readyForPickup: "픽업 준비 완료",
  OrderStatus.preparing: "상품 준비중",
  OrderStatus.shipping: "배송중",
  OrderStatus.delivered: "배송 완료",
};
