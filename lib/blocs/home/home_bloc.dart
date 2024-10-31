import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/history_item.dart';
import 'package:onlyveyou/models/home_model.dart';
import 'package:onlyveyou/screens/history/widgets/dummy_history.dart';

// 이벤트 정의 - HomeEvent는 홈 화면에서 발생하는 이벤트의 기본 클래스 역할
abstract class HomeEvent {}

// 홈 데이터를 처음 로드할 때 발생하는 이벤트
class LoadHomeData extends HomeEvent {}

// 홈 데이터를 새로고침할 때 발생하는 이벤트
class RefreshHomeData extends HomeEvent {}

// 더 많은 상품 데이터를 로드할 때 발생하는 이벤트
class LoadMoreProducts extends HomeEvent {}

// 좋아요 토글 이벤트
class ToggleProductFavorite extends HomeEvent {
  final HistoryItem item;
  ToggleProductFavorite(this.item);
}

// 상태 정의 - HomeState는 홈 화면의 상태를 나타내는 기본 클래스 역할
abstract class HomeState {}

// 초기 상태 - 화면에 아무것도 로드되지 않았을 때 사용
class HomeInitial extends HomeState {}

// 로딩 상태 - 데이터 로딩 중을 나타냄
class HomeLoading extends HomeState {}

// 로드 완료 상태 - 데이터가 로드된 상태를 나타냄
class HomeLoaded extends HomeState {
  final List<BannerItem> bannerItems; // 배너 아이템 목록
  final List<HistoryItem> recommendedProducts; // 추천 상품 목록
  final List<HistoryItem> popularProducts; // 인기 상품 목록
  final bool isLoading; // 로딩 상태 여부

  HomeLoaded({
    required this.bannerItems,
    required this.recommendedProducts,
    required this.popularProducts,
    this.isLoading = false,
  });

  // 상태를 복사하면서 일부 속성을 변경할 수 있는 메서드 (Immutable한 상태 유지)
  HomeLoaded copyWith({
    List<BannerItem>? bannerItems,
    List<HistoryItem>? recommendedProducts,
    List<HistoryItem>? popularProducts,
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

// 에러 상태 - 데이터 로드 실패 시 사용
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

// 홈 화면에 대한 BLoC 클래스
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        // 배너 데이터는 그대로 유지
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

        // dummyHistoryItems에서 데이터 가져오기
        final allItems = List<HistoryItem>.from(dummyHistoryItems);

        // 추천 상품: 전체 아이템을 추천 상품으로 사용
        final recommendedProducts = allItems;

        // 인기 상품: isBest가 true인 아이템만 필터링
        final popularProducts = allItems.where((item) => item.isBest).toList();

        emit(HomeLoaded(
          bannerItems: bannerItems,
          recommendedProducts: recommendedProducts,
          popularProducts: popularProducts,
        ));
      } catch (e) {
        emit(HomeError('데이터를 불러오는데 실패했습니다.'));
      }
    });

    on<ToggleProductFavorite>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;

        final updatedRecommended = currentState.recommendedProducts.map((item) {
          if (item.id == event.item.id) {
            return HistoryItem(
              id: item.id,
              title: item.title,
              imageUrl: item.imageUrl,
              price: item.price,
              originalPrice: item.originalPrice,
              discountRate: item.discountRate,
              isBest: item.isBest,
              isFavorite: !item.isFavorite,
              rating: item.rating,
              reviewCount: item.reviewCount,
            );
          }
          return item;
        }).toList();

        final updatedPopular = currentState.popularProducts.map((item) {
          if (item.id == event.item.id) {
            return HistoryItem(
              id: item.id,
              title: item.title,
              imageUrl: item.imageUrl,
              price: item.price,
              originalPrice: item.originalPrice,
              discountRate: item.discountRate,
              isBest: item.isBest,
              isFavorite: !item.isFavorite,
              rating: item.rating,
              reviewCount: item.reviewCount,
            );
          }
          return item;
        }).toList();

        emit(HomeLoaded(
          bannerItems: currentState.bannerItems,
          recommendedProducts: updatedRecommended,
          popularProducts: updatedPopular,
        ));
      }
    });

    // 새로고침 이벤트 핸들러
    on<RefreshHomeData>((event, emit) async {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith(isLoading: true));
        try {
          await Future.delayed(Duration(seconds: 1)); // 새로고침 시뮬레이션
          emit(currentState.copyWith(isLoading: false));
        } catch (e) {
          emit(HomeError('새로고침에 실패했습니다.'));
        }
      }
    });

    // 더 많은 상품 로드 이벤트 핸들러
    on<LoadMoreProducts>((event, emit) async {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith(isLoading: true));
        try {
          await Future.delayed(Duration(seconds: 1)); // 로딩 시뮬레이션
          emit(currentState.copyWith(isLoading: false));
        } catch (e) {
          emit(HomeError('추가 상품을 불러오는데 실패했습니다.'));
        }
      }
    });
  }
}
