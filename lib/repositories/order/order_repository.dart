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

  Future<List<OrderModel>> getAvailableReviewOrders() async {
    final userId = await OnlyYouSharedPreference().getCurrentUserId();
    try {
      final userOrdersQuery = await firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      if (userOrdersQuery.docs.isEmpty) {
        print('해당 사용자의 주문이 없습니다.');
        return [];
      }

      final querySnapshot = await firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: [
        OrderStatus.readyForPickup.name,
        OrderStatus.delivered.name
      ]).get();

      // querySnapshot이 비어있으면 빈 리스트 반환
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final orders = querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();

      return orders;
    } catch (e) {
      print('완료된 주문 데이터 가져오기 실패: $e');
      return [];
    }
  }

  Future<List<OrderModel>> fetchOrder() async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      QuerySnapshot querySnapshot = await firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      // 문서들을 OrderModel 리스트로 변환
      List<OrderModel> orders = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Firestore 문서를 OrderModel로 변환
        return OrderModel.fromMap({
          ...data,
          'id': doc.id, // Firestore 문서 ID를 id로 포함
        });
      }).toList();

      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
}
