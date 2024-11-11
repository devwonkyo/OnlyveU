import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/product_model.dart';

class RankingRepository {
  final FirebaseFirestore _firestore;

  // FirebaseFirestore 인스턴스를 주입받아 초기화. 기본적으로 FirebaseFirestore.instance 사용
  RankingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 특정 카테고리의 랭킹 상품을 가져오는 메서드
  Future<List<ProductModel>> getRankingProducts(String? categoryId) async {
    try {
      print('Fetching ranking products for categoryId: $categoryId');
      Query query =
          _firestore.collection('products'); // Firestore의 'products' 컬렉션을 참조

      // 카테고리 ID가 제공된 경우, 해당 카테고리로 필터링하여 쿼리 수행
      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
        final QuerySnapshot snapshot = await query.get(); // 쿼리 결과 가져오기

        // 쿼리 결과를 ProductModel 목록으로 변환
        var products = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['productId'] = doc.id; // 문서 ID를 productId로 설정
          return ProductModel.fromMap(data); // ProductModel 객체로 변환
        }).toList();

        // 판매량(salesVolume)을 기준으로 내림차순 정렬
        products.sort((a, b) => b.salesVolume.compareTo(a.salesVolume));

        // 상위 10개의 상품만 반환
        return products.take(10).toList();
      } else {
        // 카테고리 ID가 없으면 전체 상위 랭킹 상품을 가져옴
        return await _getTopProducts();
      }
    } catch (e) {
      print('Error in getRankingProducts: $e');
      // 에러 발생 시 예외 던짐
      throw Exception('랭킹 상품을 불러오는데 실패했습니다.');
    }
  }

  // 판매량을 기준으로 전체 상위 10개의 상품을 가져오는 메서드
  Future<List<ProductModel>> _getTopProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('salesVolume', descending: true) // 판매량 내림차순 정렬
          .limit(10) // 상위 10개의 상품 제한
          .get();

      // 쿼리 결과를 ProductModel 목록으로 변환하여 반환
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id; // 문서 ID를 productId로 설정
        return ProductModel.fromMap(data); // ProductModel 객체로 변환
      }).toList();
    } catch (e) {
      print('Error in _getTopProducts: $e');
      // 에러 발생 시 예외 던짐
      throw Exception('상품을 불러오는데 실패했습니다.');
    }
  }

  //홈화면 좋아요
  Future<void> toggleProductFavorite(String productId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // 1. 제품 문서 가져오기
        final productDoc = _firestore.collection('products').doc(productId);
        final userDoc = _firestore.collection('users').doc(userId);

        final productSnapshot = await transaction.get(productDoc);
        final userSnapshot = await transaction.get(userDoc);

        if (!productSnapshot.exists) {
          throw Exception('상품을 찾을 수 없습니다.');
        }

        // 2. favoriteList와 likedItems 업데이트
        List<String> favoriteList =
            List<String>.from(productSnapshot.get('favoriteList') ?? []);
        List<String> likedItems = List<String>.from(
            userSnapshot.exists ? userSnapshot.get('likedItems') ?? [] : []);

        if (favoriteList.contains(userId)) {
          favoriteList.remove(userId);
          likedItems.remove(productId);
        } else {
          favoriteList.add(userId);
          likedItems.add(productId);
        }

        // 3. 두 컬렉션 모두 업데이트
        transaction.update(productDoc, {'favoriteList': favoriteList});
        if (!userSnapshot.exists) {
          transaction.set(userDoc, {'likedItems': likedItems});
        } else {
          transaction.update(userDoc, {'likedItems': likedItems});
        }
      });
    } catch (e) {
      print('Error toggling favorite: $e');
      throw Exception('좋아요 처리에 실패했습니다.');
    }
  }

  Future<void> addToCart(String productId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        List<String> cartItems = List<String>.from(
            userSnapshot.exists ? userSnapshot.get('cartItems') ?? [] : []);

        if (!cartItems.contains(productId)) {
          cartItems.add(productId);

          if (!userSnapshot.exists) {
            transaction.set(userDoc, {'cartItems': cartItems});
          } else {
            transaction.update(userDoc, {'cartItems': cartItems});
          }
        }
      });
    } catch (e) {
      print('Error adding to cart: $e');
      throw Exception('장바구니 추가에 실패했습니다.');
    }
  }
}
