import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/home/ai_recommend_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

// Events
abstract class AIRecommendEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAIRecommendations extends AIRecommendEvent {}

// States
abstract class AIRecommendState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AIRecommendInitial extends AIRecommendState {}

class AIRecommendLoading extends AIRecommendState {}

class AIRecommendLoaded extends AIRecommendState {
  final List<ProductModel> products;
  final Map<String, String> reasonMap;

  AIRecommendLoaded({
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
  AIRecommendError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class AIRecommendBloc extends Bloc<AIRecommendEvent, AIRecommendState> {
  final AIRecommendRepository repository;

  AIRecommendBloc({required this.repository}) : super(AIRecommendInitial()) {
    on<LoadAIRecommendations>(_onLoadRecommendations);
  }

  Future<void> _onLoadRecommendations(
    LoadAIRecommendations event,
    Emitter<AIRecommendState> emit,
  ) async {
    try {
      emit(AIRecommendLoading());
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final (products, reasons) =
          await repository.getRecommendedProducts(userId);
      emit(AIRecommendLoaded(products: products, reasonMap: reasons));
    } catch (e) {
      emit(AIRecommendError(message: e.toString()));
    }
  }
}
