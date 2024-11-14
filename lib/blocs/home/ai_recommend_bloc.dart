import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/home/ai_recommend_repository.dart';

// Events
abstract class AIRecommendEvent extends Equatable {
  const AIRecommendEvent();

  @override
  List<Object?> get props => [];
}

class LoadAIRecommendations extends AIRecommendEvent {
  const LoadAIRecommendations();
}

// 새로운 이벤트 추가
class UpdateUserActivityCounts extends AIRecommendEvent {
  final Map<String, int> counts;

  const UpdateUserActivityCounts(this.counts);

  @override
  List<Object?> get props => [counts];
}

// States
abstract class AIRecommendState extends Equatable {
  final Map<String, int> activityCounts;

  const AIRecommendState({
    this.activityCounts = const {
      'viewCount': 0,
      'likeCount': 0,
      'cartCount': 0,
    },
  });

  @override
  List<Object?> get props => [activityCounts];
}

class AIRecommendInitial extends AIRecommendState {
  const AIRecommendInitial() : super();
}

class AIRecommendLoading extends AIRecommendState {
  const AIRecommendLoading({required Map<String, int> activityCounts})
      : super(activityCounts: activityCounts);
}

class AIRecommendLoaded extends AIRecommendState {
  final List<ProductModel> products;
  final Map<String, String> reasonMap;

  const AIRecommendLoaded({
    required this.products,
    required this.reasonMap,
    required Map<String, int> activityCounts,
  }) : super(activityCounts: activityCounts);

  String getRecommendReason(String productId) {
    return reasonMap[productId] ?? '회원님 취향과 일치';
  }

  @override
  List<Object?> get props => [products, reasonMap, activityCounts];
}

class AIRecommendError extends AIRecommendState {
  final String message;

  const AIRecommendError({
    required this.message,
    required Map<String, int> activityCounts,
  }) : super(activityCounts: activityCounts);

  @override
  List<Object?> get props => [message, activityCounts];
}

class AIRecommendBloc extends Bloc<AIRecommendEvent, AIRecommendState> {
  final AIRecommendRepository _repository;
  StreamSubscription? _activityCountsSubscription;

  AIRecommendBloc({required AIRecommendRepository repository})
      : _repository = repository,
        super(const AIRecommendInitial()) {
    // 기존 이벤트 핸들러
    on<LoadAIRecommendations>((event, emit) async {
      try {
        emit(AIRecommendLoading(activityCounts: state.activityCounts));
        final result = await _repository.getRecommendations();
        emit(AIRecommendLoaded(
          products: result['products'],
          reasonMap: result['reasons'],
          activityCounts: state.activityCounts,
        ));
      } catch (e) {
        emit(AIRecommendError(
          message: e.toString(),
          activityCounts: state.activityCounts,
        ));
      }
    });

    // 새로운 이벤트 핸들러
    on<UpdateUserActivityCounts>((event, emit) {
      if (state is AIRecommendLoaded) {
        emit(AIRecommendLoaded(
          products: (state as AIRecommendLoaded).products,
          reasonMap: (state as AIRecommendLoaded).reasonMap,
          activityCounts: event.counts,
        ));
      } else if (state is AIRecommendLoading) {
        emit(AIRecommendLoading(activityCounts: event.counts));
      } else if (state is AIRecommendError) {
        emit(AIRecommendError(
          message: (state as AIRecommendError).message,
          activityCounts: event.counts,
        ));
      } else {
        emit(AIRecommendInitial());
      }
    });

    // 사용자 활동 데이터 구독 시작
    _startListeningToActivityCounts();
  }

  void _startListeningToActivityCounts() {
    _activityCountsSubscription?.cancel();
    _activityCountsSubscription =
        _repository.getCurrentUserActivityCountsStream().listen((counts) {
      add(UpdateUserActivityCounts(counts));
    });
  }

  @override
  Future<void> close() {
    _activityCountsSubscription?.cancel();
    return super.close();
  }
}
