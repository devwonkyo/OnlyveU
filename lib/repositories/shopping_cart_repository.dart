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
        final productDoc =
            await _firestore.collection('products').doc(productId).get();
        if (!productDoc.exists) {
          throw Exception('상품을 찾을 수 없습니다.');
        }

        final userDoc = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        // 장바구니 아이템 확인
        List<Map<String, dynamic>> cartItems = [];
        if (userSnapshot.exists &&
            userSnapshot.data()!.containsKey('cartItems')) {
          cartItems =
              List<Map<String, dynamic>>.from(userSnapshot.get('cartItems'));
        }

        // 픽업 아이템 확인
        List<Map<String, dynamic>> pickupItems = [];
        if (userSnapshot.exists &&
            userSnapshot.data()!.containsKey('pickupItems')) {
          pickupItems =
              List<Map<String, dynamic>>.from(userSnapshot.get('pickupItems'));
        }

        // 일반 배송과 픽업 모두에서 중복 체크
        bool isDuplicate =
            cartItems.any((item) => item['productId'] == productId) ||
                pickupItems.any((item) => item['productId'] == productId);

        if (isDuplicate) {
          throw Exception('duplicate_item');
        }

        final cartItem = {
          'productId': productId,
          'productName': productDoc.get('name'),
          'productImageUrl':
              (productDoc.get('productImageList') as List<dynamic>).first,
          'productPrice': int.parse(productDoc.get('price')),
          'quantity': 1,
        };

        cartItems.add(cartItem);

        if (!userSnapshot.exists) {
          transaction.set(userDoc, {'cartItems': cartItems});
        } else {
          transaction.update(userDoc, {'cartItems': cartItems});
        }
      });
    } catch (e) {
      if (e is Exception && e.toString().contains('duplicate_item')) {
        throw Exception('이 상품은 이미 장바구니에 담겨 있습니다.');
      }
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

      // cartItems가 있으면 가져오고, 없으면 빈 배열 반환
      List<Map<String, dynamic>> regularCartItems = [];
      if (userDoc.data()!.containsKey('cartItems')) {
        regularCartItems =
            List<Map<String, dynamic>>.from(userDoc.get('cartItems'));
      }

      // pickupItems가 있으면 가져오고, 없으면 빈 배열 반환
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
      throw Exception('장바구니 상품을 불러오는데 실패했습니다.');
    }
  }

  // 배송 방식 변경 (일반 -> 픽업)
  Future<void> moveToPickup(List<String> productIds) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = _firestore.collection('users').doc(userId);

      // 먼저 document 존재 여부 확인 및 pickupItems 필드 초기화
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        print('User document does not exist');
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // pickupItems 필드가 없으면 빈 배열로 초기화
      if (!docSnapshot.data()!.containsKey('pickupItems')) {
        print('Initializing pickupItems field');
        await userDoc.update({'pickupItems': []});
      }

      // 이제 transaction 실행
      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDoc);

        // 현재 cartItems와 pickupItems 가져오기
        List<Map<String, dynamic>> cartItems = List<Map<String, dynamic>>.from(
            userSnapshot.get('cartItems') ?? []);
        List<Map<String, dynamic>> pickupItems =
            List<Map<String, dynamic>>.from(
                userSnapshot.get('pickupItems') ?? []);

        print('Current cartItems count: ${cartItems.length}');
        print('Current pickupItems count: ${pickupItems.length}');

        // 선택된 상품들을 찾아서 이동
        final itemsToMove = cartItems
            .where((item) => productIds.contains(item['productId']))
            .toList();

        print('Items to move count: ${itemsToMove.length}');

        // cartItems에서 선택된 상품들 제거
        cartItems.removeWhere((item) => productIds.contains(item['productId']));

        // pickupItems에 이동할 상품들 추가
        pickupItems.addAll(itemsToMove);

        // Firestore 업데이트
        transaction.update(userDoc, {
          'cartItems': cartItems,
          'pickupItems': pickupItems,
        });

        print('Successfully moved items to pickup');
      });
    } catch (e) {
      print('Error moving items to pickup: $e');
      print('Error stack trace: ${StackTrace.current}');
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

        // 현재 cartItems와 pickupItems 가져오기
        List<Map<String, dynamic>> cartItems = List<Map<String, dynamic>>.from(
            userSnapshot.get('cartItems') ?? []);

        List<Map<String, dynamic>> pickupItems =
            List<Map<String, dynamic>>.from(
                userSnapshot.get('pickupItems') ?? []);

        // 선택된 상품들을 찾아서 이동
        final itemsToMove = pickupItems
            .where((item) => productIds.contains(item['productId']))
            .toList();

        // pickupItems에서 선택된 상품들 제거
        pickupItems
            .removeWhere((item) => productIds.contains(item['productId']));

        // cartItems에 이동할 상품들 추가
        cartItems.addAll(itemsToMove);

        // Firestore 업데이트
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
