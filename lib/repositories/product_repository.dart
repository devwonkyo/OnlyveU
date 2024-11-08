import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // import 경로 수정

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

    final allDocs = [
      ...querySnapshot.docs,
      ...categorySnapshot.docs,
      ...brandNameSnapshot.docs,
    ];

    final uniqueDocs = allDocs.toSet().toList();

    return uniqueDocs.map((doc) => ProductModel.fromMap(doc.data())).toList();
  }


  Future<ProductModel?> fetchProductById(String productId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching product data: $e");
    }
    return null;

  Future<void> fetchAndStoreAllProducts() async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();

      await _clearStoredProducts();

      await _storeProductsLocally(products);
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> _clearStoredProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('products');
    } catch (e) {
      print('Error clearing stored products: $e');
    }
  }

  Future<void> _storeProductsLocally(List<ProductModel> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productJson = products.map((product) => product.toMap()).toList();
      final productString = jsonEncode(productJson);
      await prefs.setString('products', productString);
    } catch (e) {
      print('Error storing products locally: $e');
    }
  }

  Future<List<ProductModel>> getStoredProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productString = prefs.getString('products');
      if (productString != null) {
        final List<dynamic> productJson = jsonDecode(productString);
        return productJson.map((json) => ProductModel.fromMap(json)).toList();
      }
    } catch (e) {
      print('Error getting stored products: $e');
    }
    return [];
  }

  Future<List<ProductModel>> searchLocal(String term) async {
    final storedProducts = await getStoredProducts();
    if (term.isNotEmpty) {
      return storedProducts.where((product) {
        return product.name.contains(term) ||
            product.categoryId.contains(term) ||
            product.brandName.contains(term) ||
            product.tagList.any((tag) => tag.contains(term));
      }).toList();
    } else {
      return [];
    }

  }
}
