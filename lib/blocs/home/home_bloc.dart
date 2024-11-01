import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/home_model.dart';
import 'package:onlyveyou/models/product_model.dart';

// 이벤트 정의
abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

class LoadMoreProducts extends HomeEvent {}

class ToggleProductFavorite extends HomeEvent {
  final ProductModel product;
  final String userId;
  ToggleProductFavorite(this.product, this.userId);
}

// 상태 정의
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<BannerItem> bannerItems;
  final List<ProductModel> recommendedProducts;
  final List<ProductModel> popularProducts;
  final bool isLoading;

  HomeLoaded({
    required this.bannerItems,
    required this.recommendedProducts,
    required this.popularProducts,
    this.isLoading = false,
  });

  HomeLoaded copyWith({
    List<BannerItem>? bannerItems,
    List<ProductModel>? recommendedProducts,
    List<ProductModel>? popularProducts,
    bool? isLoading,
  }) {
    return HomeLoaded(
      bannerItems: bannerItems ?? this.bannerItems,
      recommendedProducts: recommendedProducts ?? this.recommendedProducts,
      popularProducts: popularProducts ?? this.popularProducts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

// HomeBloc 구현
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseFirestore _firestore;

  HomeBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(HomeInitial()) {
    // LoadHomeData 이벤트 핸들러
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        // 배너 데이터
        final bannerItems = [
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

        // Firestore에서 추천 및 인기 상품 데이터 가져오기
        final QuerySnapshot recommendedSnapshot =
            await _firestore.collection('products').limit(5).get();

        final QuerySnapshot popularSnapshot =
            await _firestore.collection('products').limit(5).get();

        print(
            "Recommended products fetched: ${recommendedSnapshot.docs.length}");
        print("Popular products fetched: ${popularSnapshot.docs.length}");

        // 추천 및 인기 상품 변환
        final recommendedProducts = recommendedSnapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();

        final popularProducts = popularSnapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();

        emit(HomeLoaded(
          bannerItems: bannerItems,
          recommendedProducts: recommendedProducts,
          popularProducts: popularProducts,
        ));
      } catch (e) {
        print('Error loading home data: $e');
        emit(HomeError('데이터를 불러오는데 실패했습니다.'));
      }
    });

    // ToggleProductFavorite 이벤트 핸들러
    on<ToggleProductFavorite>((event, emit) async {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        try {
          // 좋아요 리스트 업데이트
          List<String> updatedFavoriteList =
              List<String>.from(event.product.favoriteList);
          if (updatedFavoriteList.contains(event.userId)) {
            updatedFavoriteList.remove(event.userId);
          } else {
            updatedFavoriteList.add(event.userId);
          }

          // Firestore 업데이트
          await _firestore
              .collection('products')
              .doc(event.product.productId)
              .update({
            'favoriteList': updatedFavoriteList,
          });

          // 로컬 상태 업데이트
          final updatedRecommended =
              currentState.recommendedProducts.map((product) {
            if (product.productId == event.product.productId) {
              return event.product.copyWith(favoriteList: updatedFavoriteList);
            }
            return product;
          }).toList();

          final updatedPopular = currentState.popularProducts.map((product) {
            if (product.productId == event.product.productId) {
              return event.product.copyWith(favoriteList: updatedFavoriteList);
            }
            return product;
          }).toList();

          emit(HomeLoaded(
            bannerItems: currentState.bannerItems,
            recommendedProducts: updatedRecommended,
            popularProducts: updatedPopular,
          ));
        } catch (e) {
          print('Error toggling favorite: $e');
        }
      }
    });

    // RefreshHomeData 이벤트 핸들러
    on<RefreshHomeData>((event, emit) async {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith(isLoading: true));

        try {
          // 데이터 새로 로드
          add(LoadHomeData());
        } catch (e) {
          print('Error refreshing data: $e');
          emit(HomeError('새로고침에 실패했습니다.'));
        }
      }
    });

    // LoadMoreProducts 이벤트 핸들러
    on<LoadMoreProducts>((event, emit) async {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith(isLoading: true));

        try {
          // 추가 상품 로드 로직
          final lastProduct = currentState.recommendedProducts.last;

          final QuerySnapshot moreProducts = await _firestore
              .collection('products')
              .orderBy('productId') // 추가된 부분: orderBy
              .startAfter([lastProduct.productId])
              .limit(5)
              .get();

          final newProducts = moreProducts.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();

          emit(currentState.copyWith(
            recommendedProducts: [
              ...currentState.recommendedProducts,
              ...newProducts
            ],
            isLoading: false,
          ));
        } catch (e) {
          print('Error loading more products: $e');
          emit(currentState.copyWith(isLoading: false));
        }
      }
    });
  }
}
