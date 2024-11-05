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
          .map(
              (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
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
          .map(
              (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
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

// 검색할때 필요해서 구현했습니다.
  Future<List<ProductModel>> search(String term) async {
    final querySnapshot = await _firestore
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: term)
        .where('name', isLessThanOrEqualTo: '$term\uf8ff')
        .orderBy('name')
        .get();

    final categorySnapshot = await _firestore
        .collection('products')
        .where('category', isGreaterThanOrEqualTo: term)
        .where('category', isLessThanOrEqualTo: '$term\uf8ff')
        .orderBy('category')
        .get();

    final brandNameSnapshot = await _firestore
        .collection('products')
        .where('brandName', isGreaterThanOrEqualTo: term)
        .where('brandName', isLessThanOrEqualTo: '$term\uf8ff')
        .orderBy('brandName')
        .get();

    final tagListSnapshot = await _firestore
        .collection('products')
        .where('tagList', arrayContains: term)
        .get();

    final allDocs = [
      ...querySnapshot.docs,
      ...categorySnapshot.docs,
      ...brandNameSnapshot.docs,
      ...tagListSnapshot.docs,
    ];

    final uniqueDocs = allDocs.toSet().toList();

    return uniqueDocs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  //랭킹탭에 파베 끌어올때 썼습니다.-근데 이거 내가 만든거 아닌가?
// 2. product_repository.dart에 추가할 메서드
  Future<List<ProductModel>> getRankingProducts(String category) async {
    try {
      Query query = _firestore.collection('products');

      // 카테고리 필터링
      if (category != '전체') {
        query = query.where('categoryId', isEqualTo: category);
      }

      // salesVolume으로 정렬하고 상위 10개 가져오기
      final QuerySnapshot snapshot = // 판매량 내림차순 정렬
          await query.orderBy('salesVolume', descending: true).limit(10).get();

      return snapshot.docs
          .map(
              (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching ranking products: $e');
      throw Exception('랭킹 상품을 불러오는데 실패했습니다.');
    }
  }
}
