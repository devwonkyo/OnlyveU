// 주로 데이터 소스와 관련된 비즈니스 로직을 포함하는 곳으로,
// API 호출, Firebase 연동, 로컬 데이터베이스 처리
// 등을 처리하는 클래스들을 배치합니다.
//
// repository를 사용하여 데이터 접근과 관련된 코드가 정리되어 있고,
// BLoC이나 Provider와 같은 상태 관리 로직에서
// 데이터를 깔끔하게 관리할 수 있도록 분리합니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlyveyou/models/home_model.dart';
import 'package:onlyveyou/models/product_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore;

  HomeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 배너 데이터 가져오기
  List<BannerItem> getBannerItems() {
    return [
      BannerItem(
        title: '럭키 럭스에디트\n최대 2만원 혜택',
        subtitle: '쿠폰부터 100% 리워드까지',
        backgroundColor: Colors.black,
      ),
      BannerItem(
        title: '가을 준비하기\n최대 50% 할인',
        subtitle: '시즌 프리뷰 특가전',
        backgroundColor: Color(0xFF8B4513),
      ),
      BannerItem(
        title: '이달의 브랜드\n특별 기획전',
        subtitle: '인기 브랜드 혜택 모음',
        backgroundColor: Color(0xFF4A90E2),
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
      // 트랜잭션 시작
      await _firestore.runTransaction((transaction) async {
        // 1. 제품 문서 가져오기
        final productDoc = _firestore.collection('products').doc(productId);
        final productSnapshot = await transaction.get(productDoc);

        // 2. 사용자 문서 가져오기
        final userDoc = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        // 제품의 favoriteList 업데이트
        List<String> favoriteList =
            List<String>.from(productSnapshot.get('favoriteList') ?? []);

        // 사용자의 likedItems 업데이트
        List<String> likedItems =
            List<String>.from(userSnapshot.get('likedItems') ?? []);

        if (favoriteList.contains(userId)) {
          // 좋아요 취소
          favoriteList.remove(userId);
          likedItems.remove(productId);
        } else {
          // 좋아요 추가
          favoriteList.add(userId);
          likedItems.add(productId);
        }

        // 트랜잭션으로 두 문서 동시 업데이트
        transaction.update(productDoc, {'favoriteList': favoriteList});
        //transaction.update(userDoc, {'likedItems': likedItems});
      });
    } catch (e) {
      print('Error toggling favorite: $e');
      throw Exception('좋아요 처리에 실패했습니다.');
    }
  }
}
// home_repository.dart의 toggleProductFavorite 메서드 수정
