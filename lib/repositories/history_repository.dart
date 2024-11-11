import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore;
  final _prefs = OnlyYouSharedPreference();

  HistoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ProductModel>> fetchHistoryItems() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('registrationDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching history items: $e');
      throw Exception('히스토리 아이템을 불러오는데 실패했습니다.');
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
////////
