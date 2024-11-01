import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/history_item.dart';
import 'package:onlyveyou/models/product_model.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore;

  HistoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Firestore에서 ProductModel을 불러오고 HistoryItem으로 변환하여 반환
  Future<List<HistoryItem>> fetchHistoryItems() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('products').get();

      return snapshot.docs.map((doc) {
        final product = ProductModel.fromFirestore(doc);
        return HistoryItem(
          id: product.productId,
          title: product.name,
          imageUrl: product.productImageList.isNotEmpty
              ? product.productImageList[0]
              : '',
          price: int.parse(product.price),
          originalPrice: product.discountedPrice,
          discountRate: product.discountPercent,
          isBest: product.isBest,
          isFavorite:
              product.favoriteList.contains('currentUserId'), // 실제 유저 ID 사용 필요
          rating: product.rating,
          reviewCount: product.reviewCount,
        );
      }).toList();
    } catch (e) {
      print('Error fetching history items: $e');
      throw Exception('히스토리 아이템을 불러오는데 실패했습니다.');
    }
  }
}
