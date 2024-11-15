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

class UpdateUserActivityCounts extends AIRecommendEvent {
  final Map<String, int> counts;

  const UpdateUserActivityCounts(this.counts);

  @override
  List<Object?> get props => [counts];
}

// States
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

class AIRecommendInitial extends AIRecommendState {
  AIRecommendInitial({Map<String, int>? activityCounts})
      : super(activityCounts: activityCounts);
}

class AIRecommendLoading extends AIRecommendState {
  AIRecommendLoading({required Map<String, int> activityCounts})
      : super(activityCounts: activityCounts);
}

class AIRecommendLoaded extends AIRecommendState {
  final List<ProductModel> products;
  final Map<String, String> reasonMap;

  AIRecommendLoaded({
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

  AIRecommendError({
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
        super(AIRecommendInitial()) {
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

    on<UpdateUserActivityCounts>((event, emit) {
      if (state is AIRecommendLoaded) {
        final currentState = state as AIRecommendLoaded;
        emit(AIRecommendLoaded(
          products: currentState.products,
          reasonMap: currentState.reasonMap,
          activityCounts: event.counts,
        ));
      } else if (state is AIRecommendLoading) {
        emit(AIRecommendLoading(activityCounts: event.counts));
      } else if (state is AIRecommendError) {
        final currentState = state as AIRecommendError;
        emit(AIRecommendError(
          message: currentState.message,
          activityCounts: event.counts,
        ));
      } else {
        emit(AIRecommendInitial(activityCounts: event.counts));
      }
    });

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
  Future<void> close() async {
    await _activityCountsSubscription?.cancel();
    return super.close();
  }
}
