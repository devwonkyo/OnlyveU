import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/product_model.dart'; // import 경로 수정

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 추천 상품 가져오기
  Future<List<ProductModel>> getRecommendedProducts() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('products').limit(5).get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching recommended products: $e');
      throw Exception('추천 상품을 불러오는데 실패했습니다.'); // 오류 메시지 구체화
    }
  }

  Future<List<ProductModel>> getPopularProducts() async {
    try {
      // Firestore에서 조건 없이 상위 3개의 문서 가져오기
      final QuerySnapshot snapshot =
          await _firestore.collection('products').limit(3).get();

      // 데이터 확인을 위한 로그 추가
      print("Products fetched: ${snapshot.docs.length}");

      // ProductModel로 변환 후 반환
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching popular products: $e');
      throw Exception('인기 상품을 불러오는데 실패했습니다.');
    }
  }

  // 좋아요 토글 처리
  Future<void> toggleFavorite(
      String productId, List<String> favoriteList) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'favoriteList': favoriteList});
    } catch (e) {
      print('Error toggling favorite: $e');
      throw Exception('좋아요 처리에 실패했습니다.');
    }
  }

  // 단일 상품 조회
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('products').doc(productId).get();

      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching product: $e');
      throw Exception('상품을 불러오는데 실패했습니다.');
    }
  }
}
