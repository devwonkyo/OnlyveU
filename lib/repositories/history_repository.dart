import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';
import 'package:onlyveyou/models/history_item.dart';
import 'package:onlyveyou/models/product_model.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore;

  HistoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<HistoryItem>> fetchHistoryItems() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('products').get();
      // return snapshot.docs.map((doc) {
      //   final product = ProductModel.fromFirestore(doc);
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id; // doc.id를 productId로 추가

        final product = ProductModel.fromMap(data); //알아보기
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
          isPopular: product.isPopular,
        );
      }).toList();
    } catch (e) {
      print('Error fetching history items: $e');
      throw Exception('히스토리 아이템을 불러오는데 실패했습니다.');
    }
  }
}
