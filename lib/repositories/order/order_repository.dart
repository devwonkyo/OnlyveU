// order_repository.dart
import 'package:onlyveyou/models/order_item_model.dart';
import 'package:onlyveyou/models/order_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> fetchOrders();
  Future<OrderModel> fetchOrderDetail(String orderId);
  Future<void> createOrder(OrderModel order);
  Future<void> updateOrder(OrderModel order);
  Future<void> deleteOrder(String orderId);

  // 추가: 주문 아이템을 가져오는 메서드
  Future<List<OrderItemModel>> fetchOrderItems();
}
