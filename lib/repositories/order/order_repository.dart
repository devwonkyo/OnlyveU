// order_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

class OrderRepository {
  final FirebaseFirestore firestore;

  OrderRepository({required this.firestore});

  Future<void> saveOrder(OrderModel order) async {
    try {
      final orderCollection = firestore.collection('orders');
      final doc = orderCollection.doc(); // Firestore에서 랜덤 ID 생성

      // Firestore에서 생성된 doc ID를 toMap에 포함
      final orderData = order.toMap();
      orderData['id'] = doc.id;
      
      await doc.set(orderData);
    } catch (e) {
      throw Exception('Firestore 저장 오류: $e');
    }
  }


  Future<List<OrderModel>> getOrders() async {
    final userId = await OnlyYouSharedPreference().getCurrentUserId();
    try {
      final querySnapshot = await firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      // 화살표 함수 사용
      final orders = querySnapshot.docs.map(
              (doc) => OrderModel.fromMap(doc.data())
      ).toList();

      return orders;
    } catch (e) {
      print('주문 데이터 가져오기 실패: $e');
      return [];
    }
  }
}
