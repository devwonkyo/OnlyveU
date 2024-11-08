import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/product_model.dart'; //^ ProductModel 임포트 추가

import '../utils/shared_preference_util.dart';

class ShoppingCartRepository {
  final FirebaseFirestore _firestore;

  ShoppingCartRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 장바구니 데이터 로드 메서드 추가 //^
  Future<List<ProductModel>> loadCartItems() async {
    //^
    try {
      // 1. 현재 유저의 cartItems 가져오기
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('User document not found');
        return [];
      }

      // 2. cartItems에서 상품 ID 목록 가져오기
      List<String> cartItems =
          List<String>.from(userDoc.get('cartItems') ?? []);
      print('Found ${cartItems.length} items in cart');

      if (cartItems.isEmpty) {
        return [];
      }

      // 3. 각 상품의 정보 가져오기
      final products = await Future.wait(cartItems.map((productId) async {
        final doc =
            await _firestore.collection('products').doc(productId).get();
        if (!doc.exists) {
          print('Product $productId not found');
          return null;
        }
        return doc;
      }));

      // 4. 존재하는 상품들만 ProductModel로 변환
      return products.where((doc) => doc != null).map((doc) {
        final data = doc!.data() as Map<String, dynamic>;
        data['productId'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error loading cart items: $e');
      throw Exception('장바구니 상품을 불러오는데 실패했습니다.');
    }
  }

  // 상품 제거 메서드 (중복된 메서드 정리)
  Future<void> removeProduct(String productId) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      await _firestore.runTransaction((transaction) async {
        // 상품과 유저 문서 참조

        final userDoc = _firestore.collection('users').doc(userId);

        // 현재 상태 가져오기
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists || !userSnapshot.exists) {
          throw Exception('상품 또는 사용자 정보를 찾을 수 없습니다.');
        }

        // cartItems에서 현재 상품 제거
        List<String> cartItems =
            List<String>.from(userSnapshot.get('cartItems') ?? []);
        cartItems.remove(productId);

        // 두 컬렉션 모두 업데이트

        transaction.update(userDoc, {'cartItems': cartItems});
      });
    } catch (e) {
      print('Error removing product from cart: $e');
      throw Exception('장바구니에서 상품 제거에 실패했습니다.');
    }
  }

  // 상품 좋아요 상태 업데이트
  Future<void> updateProductFavorite(
      String productId, List<String> favoriteList) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'favoriteList': favoriteList});
    } catch (e) {
      print('Error updating product favorite: $e');
      throw Exception('상품 좋아요 상태 업데이트에 실패했습니다.');
    }
  }

  // 상품 수량 업데이트
  Future<void> updateProductQuantity(String productId, int quantity) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'quantity': quantity});
    } catch (e) {
      print('Error updating product quantity: $e');
      throw Exception('상품 수량 업데이트에 실패했습니다.');
    }
  }

  // 선택된 상품들 삭제
  Future<void> removeSelectedProducts(List<String> productIds) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      await _firestore.runTransaction((transaction) async {
        final userDoc = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          throw Exception('사용자 정보를 찾을 수 없습니다.');
        }

        // cartItems에서 선택된 상품들 제거
        List<String> cartItems =
            List<String>.from(userSnapshot.get('cartItems') ?? []);
        cartItems.removeWhere((productId) => productIds.contains(productId));

        // users 컬렉션만 업데이트
        transaction.update(userDoc, {'cartItems': cartItems});
      });
    } catch (e) {
      print('Error removing selected products: $e');
      throw Exception('선택된 상품 삭제에 실패했습니다.');
    }
  }

  // 상품 배송 방식 업데이트 (일반배송 <-> 픽업)
  Future<void> updateDeliveryMethod(String productId, bool isPickup) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'isPickup': isPickup});
    } catch (e) {
      print('Error updating delivery method: $e');
      throw Exception('배송 방식 변경에 실패했습니다.');
    }
  }
}
//일단 프로덕트 컬렉션에 연동한거 다 삭제하기
