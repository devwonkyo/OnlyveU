// lib/blocs/home_bloc.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/home_model.dart';

// Events
abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

class LoadMoreProducts extends HomeEvent {}

// States
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<BannerItem> bannerItems;
  final List<String> recommendedProducts;
  final List<String> popularProducts;
  final bool isLoading;

  HomeLoaded({
    required this.bannerItems,
    required this.recommendedProducts,
    required this.popularProducts,
    this.isLoading = false,
  });

  HomeLoaded copyWith({
    List<BannerItem>? bannerItems,
    List<String>? recommendedProducts,
    List<String>? popularProducts,
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

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<LoadMoreProducts>(_onLoadMoreProducts);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // 여기서 실제 데이터를 불러오는 로직을 구현
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

      final recommendedProducts = [
        'assets/image/skin2.webp',
        'assets/image/skin3.webp',
        'assets/image/skin4.webp',
        'assets/image/banner3.png',
      ];

      final popularProducts = [
        'assets/image/banner3.png',
        'assets/image/skin2.webp',
        'assets/image/skin3.webp',
        'assets/image/skin4.webp',
      ];

      emit(HomeLoaded(
        bannerItems: bannerItems,
        recommendedProducts: recommendedProducts,
        popularProducts: popularProducts,
      ));
    } catch (e) {
      emit(HomeError('데이터를 불러오는데 실패했습니다.'));
    }
  }

  Future<void> _onRefreshHomeData(
      RefreshHomeData event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(isLoading: true));
      try {
        // 새로운 데이터를 불러오는 로직
        await Future.delayed(Duration(seconds: 2)); // 시뮬레이션을 위한 딜레이
        emit(currentState.copyWith(isLoading: false));
      } catch (e) {
        emit(HomeError('새로고침에 실패했습니다.'));
      }
    }
  }

  Future<void> _onLoadMoreProducts(
      LoadMoreProducts event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(isLoading: true));
      try {
        // 추가 상품을 불러오는 로직
        await Future.delayed(Duration(seconds: 1)); // 시뮬레이션을 위한 딜레이
        // 여기에 추가 상품 로드 로직 구현
        emit(currentState.copyWith(isLoading: false));
      } catch (e) {
        emit(HomeError('추가 상품을 불러오는데 실패했습니다.'));
      }
    }
  }
}
