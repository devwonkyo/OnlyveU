import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/home/ai_recommend_repository.dart';

// 이벤트 정의: BLoC에서 발생하는 사용자 상호작용과 관련된 이벤트들
abstract class AIRecommendEvent extends Equatable {
  const AIRecommendEvent();

  @override
  List<Object?> get props => [];
}

/// AI 추천 로드 이벤트
class LoadAIRecommendations extends AIRecommendEvent {
  const LoadAIRecommendations();
}

/// 사용자 활동 데이터 업데이트 이벤트
class UpdateUserActivityCounts extends AIRecommendEvent {
  final Map<String, int> counts;

  const UpdateUserActivityCounts(this.counts);

  @override
  List<Object?> get props => [counts];
}

// 상태 정의: BLoC의 상태를 나타내는 클래스들
abstract class AIRecommendState extends Equatable {
  final Map<String, int> activityCounts;

  AIRecommendState({
    Map<String, int>? activityCounts,
  }) : activityCounts = activityCounts ??
            {
              'viewCount': 0,
              'likeCount': 0,
              'cartCount': 0,
            };

  @override
  List<Object?> get props => [activityCounts];
}

/// 초기 상태: 앱이 처음 시작될 때 기본 상태
class AIRecommendInitial extends AIRecommendState {
  AIRecommendInitial({Map<String, int>? activityCounts})
      : super(activityCounts: activityCounts);
}

/// 로딩 상태: 추천 데이터를 로드하는 동안 표시
class AIRecommendLoading extends AIRecommendState {
  AIRecommendLoading({required Map<String, int> activityCounts})
      : super(activityCounts: activityCounts);
}

/// 로드 완료 상태: 추천 데이터가 성공적으로 로드되었을 때
class AIRecommendLoaded extends AIRecommendState {
  final List<ProductModel> products; // 추천된 상품 목록
  final Map<String, String> reasonMap; // 추천 이유 맵

  AIRecommendLoaded({
    required this.products,
    required this.reasonMap,
    required Map<String, int> activityCounts,
  }) : super(activityCounts: activityCounts);

  /// 특정 상품의 추천 이유 반환
  String getRecommendReason(String productId) {
    return reasonMap[productId] ?? '회원님 취향과 일치';
  }

  @override
  List<Object?> get props => [products, reasonMap, activityCounts];
}

/// 에러 상태: 추천 로드 중 오류가 발생했을 때
class AIRecommendError extends AIRecommendState {
  final String message; // 오류 메시지

  AIRecommendError({
    required this.message,
    required Map<String, int> activityCounts,
  }) : super(activityCounts: activityCounts);

  @override
  List<Object?> get props => [message, activityCounts];
}

// BLoC 정의: 이벤트를 처리하고 상태를 관리
class AIRecommendBloc extends Bloc<AIRecommendEvent, AIRecommendState> {
  final AIRecommendRepository _repository;
  StreamSubscription? _activityCountsSubscription;

  AIRecommendBloc({required AIRecommendRepository repository})
      : _repository = repository,
        super(AIRecommendInitial()) {
    on<LoadAIRecommendations>((event, emit) async {
      try {
        emit(AIRecommendLoading(activityCounts: state.activityCounts));
        final result = await _repository.getRecommendations();

        // private 메소드 대신 public 메소드 사용
        final allProducts = await _repository.getAllProducts();

        final productIds = List<String>.from(result['products'] ?? []);

        final recommendedProducts = allProducts
            .where((product) => productIds.contains(product.productId))
            .toList();

        final typedReasonMap = (result['reasons'] as Map<String, dynamic>?)
                ?.map((key, value) => MapEntry(key, value.toString())) ??
            {};

        emit(AIRecommendLoaded(
          products: recommendedProducts,
          reasonMap: typedReasonMap,
          activityCounts: state.activityCounts,
        ));
      } catch (e) {
        emit(AIRecommendError(
          message: e.toString(),
          activityCounts: state.activityCounts,
        ));
      }
    });

    // 사용자 활동 데이터 업데이트 이벤트 처리
    on<UpdateUserActivityCounts>((event, emit) {
      if (state is AIRecommendLoaded) {
        // 로드된 상태에서 활동 데이터 업데이트
        final currentState = state as AIRecommendLoaded;
        emit(AIRecommendLoaded(
          products: currentState.products,
          reasonMap: currentState.reasonMap,
          activityCounts: event.counts,
        ));
      } else if (state is AIRecommendLoading) {
        // 로딩 중 상태에서 활동 데이터 업데이트
        emit(AIRecommendLoading(activityCounts: event.counts));
      } else if (state is AIRecommendError) {
        // 에러 상태에서 활동 데이터 업데이트
        final currentState = state as AIRecommendError;
        emit(AIRecommendError(
          message: currentState.message,
          activityCounts: event.counts,
        ));
      } else {
        // 초기 상태에서 활동 데이터 업데이트
        emit(AIRecommendInitial(activityCounts: event.counts));
      }
    });

    // 사용자 활동 데이터 실시간 구독 시작
    _startListeningToActivityCounts();
  }

  /// 사용자 활동 데이터를 실시간으로 구독
  void _startListeningToActivityCounts() {
    _activityCountsSubscription?.cancel();
    _activityCountsSubscription =
        _repository.getCurrentUserActivityCountsStream().listen((counts) {
      add(UpdateUserActivityCounts(counts));
    });
  }

  /// 리소스 해제: 스트림 구독 취소 및 BLoC 종료
  @override
  Future<void> close() async {
    await _activityCountsSubscription?.cancel();
    return super.close();
  }
}
