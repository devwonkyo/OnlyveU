import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';
import 'package:onlyveyou/models/history_item.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore;
  final _prefs = OnlyYouSharedPreference();

  HistoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<HistoryItem>> fetchHistoryItems() async {
    try {
      // 현재 사용자 ID 가져오기
      final userId = await _prefs.getCurrentUserId();

      final QuerySnapshot snapshot =
          await _firestore.collection('products').get();

      return snapshot.docs.map((doc) {
        // doc.data()가 null이 아닌 경우만 ProductModel 생성
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          throw Exception('Product data is null for document ID: ${doc.id}');
        }

        final product = ProductModel.fromMap(data);

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
          // 하드코딩된 'currentUserId' 대신 실제 userId 사용
          isFavorite: product.favoriteList.contains(userId),
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
