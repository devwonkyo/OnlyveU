import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlyveyou/models/home_model.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';

class HomeRepository {
  final FirebaseFirestore _firestore;
  final ShoppingCartRepository _cartRepository;

  HomeRepository(
      {FirebaseFirestore? firestore, ShoppingCartRepository? cartRepository})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _cartRepository = cartRepository ?? ShoppingCartRepository();

  // 배너 데이터 가져오기
  List<BannerItem> getBannerItems() {
    return [
      BannerItem(
        imageAsset: 'assets/image/banner/b1.jpg',
        title: '', // 빈 문자열로 설정
        subtitle: '', // 빈 문자열로 설정
        backgroundColor: Colors.transparent, // 배경색 투명하게
      ),
      BannerItem(
        imageAsset: 'assets/image/banner/c1.jpg',
        title: '',
        subtitle: '',
        backgroundColor: Colors.transparent,
      ),
      BannerItem(
        imageAsset: 'assets/image/banner/d1.png',
        title: '',
        subtitle: '',
        backgroundColor: Colors.transparent,
      ),
    ];
  }

  // 추천 상품 가져오기
  Future<List<ProductModel>> getRecommendedProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isBest', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching recommended products: $e');
      throw Exception('추천 상품을 불러오는데 실패했습니다.');
    }
  }

  // 인기 상품 가져오기
  Future<List<ProductModel>> getPopularProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isPopular', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching popular products: $e');
      throw Exception('인기 상품을 불러오는데 실패했습니다.');
    }
  }

  // 추가 상품 로드
  Future<List<ProductModel>> getMoreProducts(String lastProductId) async {
    try {
      final QuerySnapshot moreProducts = await _firestore
          .collection('products')
          .orderBy('productId')
          .startAfter([lastProductId])
          .limit(5)
          .get();

      return moreProducts.docs
          .map(
              (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading more products: $e');
      throw Exception('추가 상품을 불러오는데 실패했습니다.');
    }
  }

  // 좋아요 토글 처리
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

  // 장바구니 추가 - ShoppingCartRepository 활용
  Future<void> addToCart(String productId) async {
    try {
      await _cartRepository.addToCart(productId);
    } catch (e) {
      print('Error adding to cart: $e');
      throw Exception('이 상품은 이미 장바구니에 담겨 있습니다');
    }
  }
}
