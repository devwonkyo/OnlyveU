////여기 써야할듯
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/product_model.dart';

class ShoppingCartRepository {
  final FirebaseFirestore _firestore;

  ShoppingCartRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 장바구니 데이터 로드
  Future<List<ProductModel>> loadCartItems() async {
    try {
      final snapshot = await _firestore.collection('products').limit(5).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['productId'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error loading cart items: $e');
      throw Exception('장바구니 상품을 불러오는데 실패했습니다.');
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

  // 상품 삭제
  Future<void> removeProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error removing product: $e');
      throw Exception('상품 삭제에 실패했습니다.');
    }
  }

  // 선택된 상품들 삭제
  Future<void> removeSelectedProducts(List<String> productIds) async {
    try {
      final batch = _firestore.batch();
      for (var id in productIds) {
        final docRef = _firestore.collection('products').doc(id);
        batch.delete(docRef);
      }
      await batch.commit();
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
