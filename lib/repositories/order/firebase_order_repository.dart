// // firebase_order_repository.dart
// import 'package:onlyveyou/models/order_item_model.dart';
// import 'package:onlyveyou/models/order_model.dart';
// import 'order_repository.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirebaseOrderRepository implements OrderRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   Future<List<OrderModel>> fetchOrders() async {
//     // Firebase에서 주문 목록 가져오기
//     QuerySnapshot snapshot = await _firestore.collection('orders').get();
//     return snapshot.docs.map((doc) {
//       return OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
//     }).toList();
//   }

//   @override
//   Future<OrderModel> fetchOrderDetail(String orderId) async {
//     // Firebase에서 특정 주문 상세 정보 가져오기
//     DocumentSnapshot doc =
//         await _firestore.collection('orders').doc(orderId).get();
//     if (doc.exists) {
//       return OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
//     } else {
//       throw Exception('주문을 찾을 수 없습니다.');
//     }
//   }

//   @override
//   Future<void> createOrder(OrderModel order) async {
//     // Firebase에 새로운 주문 생성
//     await _firestore
//         .collection('orders')
//         .doc(order.id)
//         .set(order.toMap());
//   }

//   @override
//   Future<void> updateOrder(OrderModel order) async {
//     // Firebase에서 주문 업데이트
//     await _firestore
//         .collection('orders')
//         .doc(order.id)
//         .update(order.toMap());
//   }

//   @override
//   Future<void> deleteOrder(String orderId) async {
//     // Firebase에서 주문 삭제
//     await _firestore.collection('orders').doc(orderId).delete();
//   }

//   @override
//   Future<List<OrderItemModel>> fetchOrderItems() {
//     // TODO: implement fetchOrderItems
//     throw UnimplementedError();
//   }



  
// }
