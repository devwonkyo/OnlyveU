import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

class HistoryData {
  final List<ProductModel> recentItems;
  final List<ProductModel> likedItems;

  HistoryData({
    required this.recentItems,
    required this.likedItems,
  });
}

class HistoryRepository {
  final FirebaseFirestore _firestore;
  final ShoppingCartRepository _cartRepository;
  final _prefs = OnlyYouSharedPreference();
  final Map<String, ProductModel> _productCache = {};

  HistoryRepository(
      {FirebaseFirestore? firestore, ShoppingCartRepository? cartRepository})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _cartRepository = cartRepository ?? ShoppingCartRepository();

  Stream<HistoryData> fetchHistoryAndLikedItems() async* {
    try {
      final String currentUserId = await _prefs.getCurrentUserId();

      yield* _firestore
          .collection('users')
          .doc(currentUserId)
          .snapshots()
          .asyncMap((userSnapshot) async {
        if (!userSnapshot.exists) {
          return HistoryData(recentItems: [], likedItems: []);
        }

        final List<String> viewHistory =
            List<String>.from(userSnapshot.data()?['viewHistory'] ?? []);
        final List<String> likedItems =
            List<String>.from(userSnapshot.data()?['likedItems'] ?? []);

        final List<ProductModel> recentProducts =
            await _fetchProductsByIds(viewHistory);
        final List<ProductModel> likedProducts =
            await _fetchProductsByIds(likedItems);

        return HistoryData(
          recentItems: recentProducts,
          likedItems: likedProducts,
        );
      });
    } catch (e) {
      print('Error fetching history and liked items: $e');
      throw Exception('상품 정보를 불러오는데 실패했습니다.');
    }
  }

  Future<List<ProductModel>> _fetchProductsByIds(
      List<String> productIds) async {
    final List<ProductModel> products = [];

    for (String productId in productIds) {
      if (_productCache.containsKey(productId)) {
        products.add(_productCache[productId]!);
        continue;
      }

      final productDoc =
          await _firestore.collection('products').doc(productId).get();
      if (productDoc.exists) {
        Map<String, dynamic> data = productDoc.data() as Map<String, dynamic>;
        data['productId'] = productDoc.id;
        final product = ProductModel.fromMap(data);
        _productCache[productId] = product;
        products.add(product);
      }
    }

    return products;
  }

  Future<void> toggleFavorite(String productId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final productRef = _firestore.collection('products').doc(productId);
        final userRef = _firestore.collection('users').doc(userId);

        final productDoc = await transaction.get(productRef);
        final userDoc = await transaction.get(userRef);

        List<String> favoriteList =
            List<String>.from(productDoc.get('favoriteList') ?? []);
        List<String> likedItems = List<String>.from(
            userDoc.exists ? userDoc.get('likedItems') ?? [] : []);

        if (favoriteList.contains(userId)) {
          favoriteList.remove(userId);
          likedItems.remove(productId);
        } else {
          favoriteList.add(userId);
          likedItems.add(productId);
        }

        transaction.update(productRef, {'favoriteList': favoriteList});
        if (userDoc.exists) {
          transaction.update(userRef, {'likedItems': likedItems});
        } else {
          transaction.set(
              userRef, {'likedItems': likedItems}, SetOptions(merge: true));
        }
      });

      _productCache.remove(productId);
    } catch (e) {
      print('Error toggling favorite: $e');
      throw Exception('좋아요 처리에 실패했습니다.');
    }
  }

  Future<void> addToCart(String productId) async {
    try {
      await _cartRepository.addToCart(productId);
    } catch (e) {
      print('Error adding to cart: $e');
      throw Exception('장바구니 추가에 실패했습니다.');
    }
  }

  Future<void> removeHistoryItem(String productId, String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        List<String> viewHistory =
            List<String>.from(userDoc.get('viewHistory') ?? []);
        viewHistory.remove(productId);

        transaction.update(userRef, {'viewHistory': viewHistory});
      });
    } catch (e) {
      print('Error removing history item: $e');
      throw Exception('최근 본 상품 삭제에 실패했습니다.');
    }
  }

  Future<void> clearHistory(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({'viewHistory': []});
    } catch (e) {
      print('Error clearing history: $e');
      throw Exception('히스토리 초기화에 실패했습니다.');
    }
  }
}
