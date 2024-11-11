import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/cart_model.dart';

import '../utils/shared_preference_util.dart';

class ShoppingCartRepository {
  final FirebaseFirestore _firestore;

  ShoppingCartRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 장바구니 데이터 로드
  Future<Map<String, List<CartModel>>> loadCartItems() async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {'regular': [], 'pickup': []};
      }

      // 일반 배송 상품 ID 목록
      List<String> regularIds =
          List<String>.from(userDoc.get('cartItems') ?? []);
      // 픽업 상품 ID 목록
      List<String> pickupIds =
          List<String>.from(userDoc.get('pickupItems') ?? []);

      // 상품 정보 가져오기
      final regularItems = await _loadCartItemsByIds(regularIds);
      final pickupItems = await _loadCartItemsByIds(pickupIds);

      return {
        'regular': regularItems,
        'pickup': pickupItems,
      };
    } catch (e) {
      print('Error loading cart items: $e');
      throw Exception('장바구니 상품을 불러오는데 실패했습니다.');
    }
  }

  // ID 목록으로 상품 정보 가져오기
  Future<List<CartModel>> _loadCartItemsByIds(List<String> productIds) async {
    if (productIds.isEmpty) return [];

    final productSnapshots = await Future.wait(productIds
        .map((id) => _firestore.collection('products').doc(id).get()));

    return productSnapshots.where((doc) => doc.exists).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CartModel(
        productId: doc.id,
        productName: data['name'] ?? '',
        productImageUrl:
            (data['productImageList'] as List<dynamic>).first.toString(),
        productPrice: int.parse(data['price'] ?? '0'),
        quantity: 1, // 기본 수량은 1
      );
    }).toList();
  }

  // 배송 방식 변경 (일반 -> 픽업)
  Future<void> moveToPickup(List<String> productIds) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      await _firestore.runTransaction((transaction) async {
        final userDoc = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        List<String> cartItems =
            List<String>.from(userSnapshot.get('cartItems') ?? []);
        List<String> pickupItems =
            List<String>.from(userSnapshot.get('pickupItems') ?? []);

        cartItems.removeWhere((id) => productIds.contains(id));
        pickupItems.addAll(productIds);

        transaction.update(userDoc, {
          'cartItems': cartItems,
          'pickupItems': pickupItems,
        });
      });
    } catch (e) {
      print('Error moving items to pickup: $e');
      throw Exception('배송 방식 변경에 실패했습니다.');
    }
  }

  // 배송 방식 변경 (픽업 -> 일반)
  Future<void> moveToRegularDelivery(List<String> productIds) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      await _firestore.runTransaction((transaction) async {
        final userDoc = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        List<String> cartItems =
            List<String>.from(userSnapshot.get('cartItems') ?? []);
        List<String> pickupItems =
            List<String>.from(userSnapshot.get('pickupItems') ?? []);

        pickupItems.removeWhere((id) => productIds.contains(id));
        cartItems.addAll(productIds);

        transaction.update(userDoc, {
          'cartItems': cartItems,
          'pickupItems': pickupItems,
        });
      });
    } catch (e) {
      print('Error moving items to regular delivery: $e');
      throw Exception('배송 방식 변경에 실패했습니다.');
    }
  }

  // 상품 삭제
  Future<void> removeProduct(String productId, bool isPickup) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = _firestore.collection('users').doc(userId);
      final field = isPickup ? 'pickupItems' : 'cartItems';

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        List<String> items = List<String>.from(snapshot.get(field) ?? []);
        items.remove(productId);
        transaction.update(userDoc, {field: items});
      });
    } catch (e) {
      print('Error removing product: $e');
      throw Exception('상품 삭제에 실패했습니다.');
    }
  }

  // 선택된 상품들 삭제
  Future<void> removeSelectedProducts(
      List<String> productIds, bool isPickup) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = _firestore.collection('users').doc(userId);
      final field = isPickup ? 'pickupItems' : 'cartItems';

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        List<String> items = List<String>.from(snapshot.get(field) ?? []);
        items.removeWhere((id) => productIds.contains(id));
        transaction.update(userDoc, {field: items});
      });
    } catch (e) {
      print('Error removing selected products: $e');
      throw Exception('선택된 상품 삭제에 실패했습니다.');
    }
  }

  // 상품 수량 업데이트
  Future<void> updateProductQuantity(String productId, int quantity) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cartQuantities')
          .doc(productId)
          .set({'quantity': quantity});
    } catch (e) {
      print('Error updating product quantity: $e');
      throw Exception('상품 수량 업데이트에 실패했습니다.');
    }
  }
}
