import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/cart_model.dart';

import '../utils/shared_preference_util.dart';

class ShoppingCartRepository {
  final FirebaseFirestore _firestore;

  ShoppingCartRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 장바구니에 상품 추가
  Future<void> addToCart(String productId) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      await _firestore.runTransaction((transaction) async {
        // 1. 상품 정보 가져오기
        final productDoc =
            await _firestore.collection('products').doc(productId).get();
        if (!productDoc.exists) {
          throw Exception('상품을 찾을 수 없습니다.');
        }

        // 2. CartModel 형태의 데이터 생성
        final cartItem = {
          'productId': productId,
          'productName': productDoc.get('name'),
          'productImageUrl':
              (productDoc.get('productImageList') as List<dynamic>).first,
          'productPrice': int.parse(productDoc.get('price')),
          'quantity': 1,
        };

        // 3. 사용자 문서 가져오기
        final userDoc = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        // 4. 현재 장바구니 아이템 목록 가져오기
        List<Map<String, dynamic>> cartItems = [];
        if (userSnapshot.exists &&
            userSnapshot.data()!.containsKey('cartItems')) {
          cartItems =
              List<Map<String, dynamic>>.from(userSnapshot.get('cartItems'));
        }

        // 5. 이미 존재하는 상품인지 확인
        final existingItemIndex =
            cartItems.indexWhere((item) => item['productId'] == productId);
        if (existingItemIndex >= 0) {
          // 이미 있으면 수량만 증가
          cartItems[existingItemIndex]['quantity'] =
              (cartItems[existingItemIndex]['quantity'] ?? 1) + 1;
        } else {
          // 없으면 새로 추가
          cartItems.add(cartItem);
        }

        // 6. Firestore 업데이트
        if (!userSnapshot.exists) {
          transaction.set(userDoc, {'cartItems': cartItems});
        } else {
          transaction.update(userDoc, {'cartItems': cartItems});
        }
      });
    } catch (e) {
      print('Error adding to cart: $e');
      throw Exception('장바구니 추가에 실패했습니다.');
    }
  }

  // 장바구니 데이터 로드
  Future<Map<String, List<CartModel>>> loadCartItems() async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {'regular': [], 'pickup': []};
      }

      print('User document data: ${userDoc.data()}');

      // cartItems가 있으면 가져오고, 없으면 빈 배열 반환
      List<Map<String, dynamic>> regularCartItems = [];
      if (userDoc.data()!.containsKey('cartItems')) {
        regularCartItems =
            List<Map<String, dynamic>>.from(userDoc.get('cartItems'));
      }

      // pickupItems는 아직 없을 수 있으므로 빈 배열로 초기화
      List<Map<String, dynamic>> pickupItems = [];
      if (userDoc.data()!.containsKey('pickupItems')) {
        pickupItems =
            List<Map<String, dynamic>>.from(userDoc.get('pickupItems'));
      }

      return {
        'regular':
            regularCartItems.map((item) => CartModel.fromMap(item)).toList(),
        'pickup': pickupItems.map((item) => CartModel.fromMap(item)).toList(),
      };
    } catch (e) {
      print('Error loading cart items: $e');
      print('Error stack trace: ${StackTrace.current}');
      throw Exception('장바구니 상품을 불러오는데 실패했습니다.');
    }
  }

  // 배송 방식 변경 (일반 -> 픽업)
  Future<void> moveToPickup(List<String> productIds) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      await _firestore.runTransaction((transaction) async {
        final userDoc = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        List<Map<String, dynamic>> cartItems = List<Map<String, dynamic>>.from(
            userSnapshot.get('cartItems') ?? []);
        List<Map<String, dynamic>> pickupItems =
            List<Map<String, dynamic>>.from(
                userSnapshot.get('pickupItems') ?? []);

        // 선택된 상품들을 cartItems에서 pickupItems로 이동
        final itemsToMove = cartItems
            .where((item) => productIds.contains(item['productId']))
            .toList();
        cartItems.removeWhere((item) => productIds.contains(item['productId']));
        pickupItems.addAll(itemsToMove);

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

        List<Map<String, dynamic>> cartItems = List<Map<String, dynamic>>.from(
            userSnapshot.get('cartItems') ?? []);
        List<Map<String, dynamic>> pickupItems =
            List<Map<String, dynamic>>.from(
                userSnapshot.get('pickupItems') ?? []);

        // 선택된 상품들을 pickupItems에서 cartItems로 이동
        final itemsToMove = pickupItems
            .where((item) => productIds.contains(item['productId']))
            .toList();
        pickupItems
            .removeWhere((item) => productIds.contains(item['productId']));
        cartItems.addAll(itemsToMove);

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
        List<Map<String, dynamic>> items =
            List<Map<String, dynamic>>.from(snapshot.get(field) ?? []);
        items.removeWhere((item) => item['productId'] == productId);
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
        List<Map<String, dynamic>> items =
            List<Map<String, dynamic>>.from(snapshot.get(field) ?? []);
        items.removeWhere((item) => productIds.contains(item['productId']));
        transaction.update(userDoc, {field: items});
      });
    } catch (e) {
      print('Error removing selected products: $e');
      throw Exception('선택된 상품 삭제에 실패했습니다.');
    }
  }

  // 상품 수량 업데이트
  Future<void> updateProductQuantity(
      String productId, int quantity, bool isPickup) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = _firestore.collection('users').doc(userId);
      final field = isPickup ? 'pickupItems' : 'cartItems';

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        List<Map<String, dynamic>> items =
            List<Map<String, dynamic>>.from(snapshot.get(field) ?? []);

        final itemIndex =
            items.indexWhere((item) => item['productId'] == productId);
        if (itemIndex >= 0) {
          items[itemIndex]['quantity'] = quantity;
          transaction.update(userDoc, {field: items});
        }
      });
    } catch (e) {
      print('Error updating product quantity: $e');
      throw Exception('상품 수량 업데이트에 실패했습니다.');
    }
  }
}
