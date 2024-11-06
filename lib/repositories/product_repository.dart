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
  Future<List<ProductModel>> getRankingProducts(String? categoryId) async {
    try {
      print('Fetching products for categoryId: $categoryId');
      Query query = _firestore.collection('products');

      if (categoryId != null) {
        // 방법 1: 단순화된 쿼리 - 인덱스 없이도 작동
        query = query.where('categoryId', isEqualTo: categoryId);
        final QuerySnapshot snapshot = await query.get();

        var products = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['productId'] = doc.id;
          return ProductModel.fromMap(data);
        }).toList();

        // Dart에서 정렬
        products.sort((a, b) => b.salesVolume.compareTo(a.salesVolume));

        // 상위 10개만 반환
        return products.take(10).toList();
      } else {
        // 전체 상품 조회 시에는 기존 방식 유지
        return await _getTopProducts();
      }
    } catch (e) {
      print('Error in getRankingProducts: $e');
      throw Exception('랭킹 상품을 불러오는데 실패했습니다.');
    }
  }

//
// 전체 상품 조회용 별도 메서드
  Future<List<ProductModel>> _getTopProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('salesVolume', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error in _getTopProducts: $e');
      throw Exception('상품을 불러오는데 실패했습니다.');
    }
  }

  /////
// //방법 2: 두 단계 쿼리 방식
//   Future<List<ProductModel>> getRankingProductsAlternative(
//       String? categoryId) async {
//     try {
//       if (categoryId != null) {
//         // 1단계: categoryId로 먼저 필터링
//         final QuerySnapshot categorySnapshot = await _firestore
//             .collection('products')
//             .where('categoryId', isEqualTo: categoryId)
//             .get();
//
//         // 2단계: salesVolume으로 정렬하고 상위 10개 추출
//         final products = categorySnapshot.docs.map((doc) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//           data['productId'] = doc.id;
//           return ProductModel.fromMap(data);
//         }).toList()
//           ..sort((a, b) => b.salesVolume.compareTo(a.salesVolume));
//
//         return products.take(10).toList();
//       } else {
//         return await _getTopProducts();
//       }
//     } catch (e) {
//       print('Error in getRankingProductsAlternative: $e');
//       throw Exception('랭킹 상품을 불러오는데 실패했습니다.');
//     }
//   }
}
