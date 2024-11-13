// import 'package:onlyveyou/models/order_model.dart';
// import 'package:onlyveyou/models/order_item_model.dart';
// import 'package:onlyveyou/models/delivery_info_model.dart';
// import 'order_repository.dart';

// class MockOrderRepository implements OrderRepository {
//   final List<OrderModel> _orders = [
//     OrderModel(
//       id: 'order_001',
//       userId: 'user_123',
//       items: [
//         OrderItemModel(
//           productId: 'product_001',
//           productName: '[3분모공각질케어] 비플레인 녹두 모공 클레이팩',
//           productImageUrl:
//               'https://cdn.hitnews.co.kr/news/photo/202407/56284_75421_137.jpg', // 샘플 이미지 URL
//           productPrice: 5000,
//           quantity: 2,
//         ),
//         OrderItemModel(
//           productId: 'product_002',
//           productName: '라보에이치 두피강화 트리트먼트',
//           productImageUrl:
//               'https://cdn.hitnews.co.kr/news/photo/202407/56284_75421_137.jpg', // 샘플 이미지 URL
//           productPrice: 4000,
//           quantity: 1,
//         ),
//       ],
//       status: OrderStatus.pending,
//       orderType: OrderType.pickup,
//       createdAt: DateTime.now(),
//       deliveryInfo: DeliveryInfoModel(
//         //배송지 등록과 배송 요청사항을 여기다가 추가
//         deliveryName: '',
//         address: '',
//         detailAddress: '',
//         recipientName: '',
//         recipientPhone: '',
//       ),
//     ),
//   ];

//   @override
//   Future<List<OrderModel>> fetchOrders() async => _orders;

//   @override
//   Future<OrderModel> fetchOrderDetail(String orderId) async =>
//       _orders.firstWhere((order) => order.id == orderId);

//   @override
//   Future<void> createOrder(OrderModel order) async => _orders.add(order);

//   @override
//   Future<void> updateOrder(OrderModel order) async {
//     int index = _orders.indexWhere((o) => o.id == order.id);
//     if (index != -1) {
//       _orders[index] = order;
//     }
//   }

//   @override
//   Future<void> deleteOrder(String orderId) async =>
//       _orders.removeWhere((order) => order.id == orderId);

//   @override
//   Future<List<OrderItemModel>> fetchOrderItems() async {
//     // 첫 번째 OrderModel 안의 OrderItemModel 데이터를 반환
//     return _orders.isNotEmpty ? _orders[0].items : [];
//   }

//   @override
//   Future<OrderType> getOrderType() async {
//     return _orders.isNotEmpty ? _orders[0].orderType : OrderType.delivery;
//   }

//   @override
//   Future<DeliveryInfoModel?> getDeliveryInfo() async {
//     if (_orders.isNotEmpty && _orders[0].orderType == OrderType.delivery) {
//       return _orders[0].deliveryInfo;
//     } else {
//       return null;
//     }
//   }
// }
