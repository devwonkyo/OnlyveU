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

// States
abstract class AIRecommendState extends Equatable {
  const AIRecommendState();

  @override
  List<Object?> get props => [];
}

class AIRecommendInitial extends AIRecommendState {
  const AIRecommendInitial();
}

class AIRecommendLoading extends AIRecommendState {
  const AIRecommendLoading();
}

class AIRecommendLoaded extends AIRecommendState {
  final List<ProductModel> products;
  final Map<String, String> reasonMap;

  const AIRecommendLoaded({
    required this.products,
    required this.reasonMap,
  });

  String getRecommendReason(String productId) {
    return reasonMap[productId] ?? '회원님 취향과 일치';
  }

  @override
  List<Object?> get props => [products, reasonMap];
}

class AIRecommendError extends AIRecommendState {
  final String message;
  const AIRecommendError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AIRecommendBloc extends Bloc<AIRecommendEvent, AIRecommendState> {
  final AIRecommendRepository _repository;

  AIRecommendBloc({required AIRecommendRepository repository})
      : _repository = repository,
        super(const AIRecommendInitial()) {
    on<LoadAIRecommendations>((event, emit) async {
      try {
        emit(const AIRecommendLoading());
        final result = await _repository.getRecommendations();
        emit(AIRecommendLoaded(
            products: result['products'], reasonMap: result['reasons']));
      } catch (e) {
        emit(AIRecommendError(message: e.toString()));
      }
    });
  }
}
