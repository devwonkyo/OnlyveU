import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore;
  final ShoppingCartRepository _cartRepository;
  final _prefs = OnlyYouSharedPreference(); // 추가
  final Map<String, ProductModel> _productCache = {};

  HistoryRepository(
      {FirebaseFirestore? firestore,
      ShoppingCartRepository? cartRepository // 추가
      })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _cartRepository = cartRepository ?? ShoppingCartRepository();

  Stream<List<ProductModel>> fetchHistoryItems() async* {
    try {
      final String currentUserId = await _prefs.getCurrentUserId();

      yield* _firestore
          .collection('users')
          .doc(currentUserId)
          .snapshots()
          .asyncMap((userSnapshot) async {
        if (!userSnapshot.exists) return [];

        final List<String> viewHistory =
            List<String>.from(userSnapshot.data()?['viewHistory'] ?? []);

        final List<ProductModel> products = [];
        for (String productId in viewHistory) {
          // 캐시된 제품이 있으면 사용
          if (_productCache.containsKey(productId)) {
            products.add(_productCache[productId]!);
            continue;
          }

          // 캐시에 없으면 Firebase에서 가져옴
          final productDoc =
              await _firestore.collection('products').doc(productId).get();
          if (productDoc.exists) {
            Map<String, dynamic> data =
                productDoc.data() as Map<String, dynamic>;
            data['productId'] = productDoc.id;
            final product = ProductModel.fromMap(data);
            _productCache[productId] = product; // 캐시에 저장
            products.add(product);
          }
        }
        return products;
      });
    } catch (e) {
      print('Error fetching history items: $e');
      throw Exception('최근 본 상품을 불러오는데 실패했습니다.');
    }
  }

  Future<void> toggleFavorite(String productId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final productDoc = _firestore.collection('products').doc(productId);
        final userDoc = _firestore.collection('users').doc(userId);

        final productSnapshot = await transaction.get(productDoc);
        final userSnapshot = await transaction.get(userDoc);

        // favoriteList와 likedItems 업데이트
        List<String> favoriteList =
            List<String>.from(productSnapshot.get('favoriteList') ?? []);
        List<String> likedItems = List<String>.from(
            userSnapshot.exists ? userSnapshot.get('likedItems') ?? [] : []);

        // 삭제 로직
        favoriteList.remove(userId);
        likedItems.remove(productId);

        // 트랜잭션으로 두 컬렉션 동시 업데이트
        transaction.update(productDoc, {'favoriteList': favoriteList});
        if (userSnapshot.exists) {
          transaction.update(userDoc, {'likedItems': likedItems});
        } else {
          transaction.set(userDoc, {'likedItems': likedItems});
        }
      });
    } catch (e) {
      print('Error removing favorite: $e');
      throw Exception('좋아요 삭제 처리에 실패했습니다.');
    }
  } //^

  //장바구니
  Future<void> addToCart(String productId) async {
    try {
      await _cartRepository.addToCart(productId); // ShoppingCartRepository 사용
    } catch (e) {
      print('Error adding to cart: $e');
      throw Exception('장바구니 추가에 실패했습니다.');
    }
  }
}
////////
