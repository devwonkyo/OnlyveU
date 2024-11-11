import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/product_model.dart';

//UI -> Bloc -> Repository -> Firestore -> Repository -> Bloc -> UI
// 커스텀 예외 클래스 정의: 특가 상품 로딩 중 발생하는 예외 처리
class TodaySaleException implements Exception {
  final String message;
  final dynamic error;

  TodaySaleException(this.message, [this.error]);

  @override
  String toString() => 'TodaySaleException: $message';
}

// TodaySaleRepository: Firestore에서 특가 상품을 가져오는 클래스
class TodaySaleRepository {
  final FirebaseFirestore _firestore;

  // 특가 상품 최소 할인율 상수 설정 (재사용성 및 유지보수성 강화)
  static const int MIN_DISCOUNT_PERCENT = 40;

  TodaySaleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 특가 상품 목록을 Firestore에서 가져오는 메서드
  Future<List<ProductModel>> getTodaySaleProducts() async {
    try {
      // 특가 상품 쿼리 빌드 및 실행
      final Query query = _buildTodaySaleQuery();
      final QuerySnapshot snapshot = await query.get();

      // 쿼리 결과를 ProductModel 목록으로 변환하여 반환
      return _convertToProductModels(snapshot);
    } catch (e) {
      print('Error in repository: $e');
      // 커스텀 예외 던지기 (에러 메시지 포함)
      throw TodaySaleException('특가 상품을 불러오는데 실패했습니다.', e);
    }
  }

  // 특가 상품 쿼리를 생성하는 메서드 (가독성을 위해 분리)
  Query _buildTodaySaleQuery() {
    return _firestore
        .collection('products')
        .where('discountPercent', isGreaterThanOrEqualTo: MIN_DISCOUNT_PERCENT)
        .orderBy('discountPercent', descending: true);
  }

  // Firestore QuerySnapshot을 ProductModel 목록으로 변환하는 메서드
  List<ProductModel> _convertToProductModels(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['productId'] = doc.id; // 문서 ID를 productId로 추가
      return ProductModel.fromMap(data);
    }).toList();
  }

  // 카테고리별 특가 상품을 Firestore에서 가져오는 메서드
  Future<List<ProductModel>> getTodaySaleProductsByCategory(
      String categoryId) async {
    try {
      // 기본 특가 상품 쿼리에 카테고리 필터 추가
      final query =
          _buildTodaySaleQuery().where('categoryId', isEqualTo: categoryId);
      final snapshot = await query.get();

      // 쿼리 결과를 ProductModel 목록으로 변환하여 반환
      return _convertToProductModels(snapshot);
    } catch (e) {
      // 카테고리별 예외 처리
      throw TodaySaleException('카테고리별 특가 상품을 불러오는데 실패했습니다.', e);
    }
  }

  // today_sale_repository.dart
  Future<void> toggleProductFavorite(String productId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final productDoc = _firestore.collection('products').doc(productId);
        final userDoc = _firestore.collection('users').doc(userId);

        final productSnapshot = await transaction.get(productDoc);
        final userSnapshot = await transaction.get(userDoc);

        if (!productSnapshot.exists) {
          throw Exception('상품을 찾을 수 없습니다.');
        }

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

  // 장바구니 추가 메서드
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
