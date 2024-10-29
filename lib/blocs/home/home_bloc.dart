import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/home_model.dart';

// 이벤트 정의 - HomeEvent는 홈 화면에서 발생하는 이벤트의 기본 클래스 역할
abstract class HomeEvent {}

// 홈 데이터를 처음 로드할 때 발생하는 이벤트
class LoadHomeData extends HomeEvent {}

// 홈 데이터를 새로고침할 때 발생하는 이벤트
class RefreshHomeData extends HomeEvent {}

// 더 많은 상품 데이터를 로드할 때 발생하는 이벤트
class LoadMoreProducts extends HomeEvent {}

// 상태 정의 - HomeState는 홈 화면의 상태를 나타내는 기본 클래스 역할
abstract class HomeState {}

// 초기 상태 - 화면에 아무것도 로드되지 않았을 때 사용
class HomeInitial extends HomeState {}

// 로딩 상태 - 데이터 로딩 중을 나타냄
class HomeLoading extends HomeState {}

// 로드 완료 상태 - 데이터가 로드된 상태를 나타냄
class HomeLoaded extends HomeState {
  final List<BannerItem> bannerItems; // 배너 아이템 목록
  final List<String> recommendedProducts; // 추천 상품 목록
  final List<String> popularProducts; // 인기 상품 목록
  final bool isLoading; // 로딩 상태 여부

  HomeLoaded({
    required this.bannerItems,
    required this.recommendedProducts,
    required this.popularProducts,
    this.isLoading = false, // 기본값 false로 로딩 상태 초기화
  });

  // 상태를 복사하면서 일부 속성을 변경할 수 있는 메서드 (Immutable한 상태 유지)
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

// 에러 상태 - 데이터 로드 실패 시 사용
class HomeError extends HomeState {
  final String message; // 오류 메시지
  HomeError(this.message); // 메시지를 필수로 받음
}

// 홈 화면에 대한 BLoC 클래스
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    // 이벤트 발생 시 실행될 핸들러를 등록
    on<LoadHomeData>(_onLoadHomeData); // LoadHomeData 이벤트 처리
    on<RefreshHomeData>(_onRefreshHomeData); // RefreshHomeData 이벤트 처리
    on<LoadMoreProducts>(_onLoadMoreProducts); // LoadMoreProducts 이벤트 처리
  }

  // LoadHomeData 이벤트 핸들러
  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading()); // 로딩 상태로 전환
    try {
      // 실제 데이터 로드 로직 (이 예제에서는 가상의 데이터를 사용)
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

      // 데이터 로드 완료 상태로 전환
      emit(HomeLoaded(
        bannerItems: bannerItems,
        recommendedProducts: recommendedProducts,
        popularProducts: popularProducts,
      ));
    } catch (e) {
      // 데이터 로드 실패 시 에러 상태로 전환
      emit(HomeError('데이터를 불러오는데 실패했습니다.'));
    }
  }

  // RefreshHomeData 이벤트 핸들러
  Future<void> _onRefreshHomeData(
      RefreshHomeData event, Emitter<HomeState> emit) async {
    // 현재 상태가 HomeLoaded인 경우만 새로고침
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(isLoading: true)); // 새로고침 로딩 상태로 전환
      try {
        // 새로운 데이터를 불러오는 로직 (시뮬레이션으로 딜레이 추가)
        await Future.delayed(Duration(seconds: 1));
        emit(currentState.copyWith(isLoading: false)); // 로딩 완료 상태로 전환
      } catch (e) {
        emit(HomeError('새로고침에 실패했습니다.')); // 에러 상태로 전환
      }
    }
  }

  // LoadMoreProducts 이벤트 핸들러
  Future<void> _onLoadMoreProducts(
      LoadMoreProducts event, Emitter<HomeState> emit) async {
    // 현재 상태가 HomeLoaded인 경우만 추가 로드
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(isLoading: true)); // 로딩 상태 전환
      try {
        // 추가 상품을 불러오는 로직 (시뮬레이션으로 딜레이 추가)
        await Future.delayed(Duration(seconds: 1));
        // 여기에 추가 상품 로드 로직 구현 (현재는 로직 없음)
        emit(currentState.copyWith(isLoading: false)); // 로딩 완료 상태 전환
      } catch (e) {
        emit(HomeError('추가 상품을 불러오는데 실패했습니다.')); // 에러 상태로 전환
      }
    }
  }
}
