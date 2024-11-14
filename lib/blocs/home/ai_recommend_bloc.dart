import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/home/ai_recommend_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

// Events
abstract class AIRecommendEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAIRecommendations extends AIRecommendEvent {}

class ToggleProductFavorite extends AIRecommendEvent {
  final ProductModel product;
  final String userId;

  ToggleProductFavorite(this.product, this.userId);

  @override
  List<Object?> get props => [product, userId];
}

class AddToCart extends AIRecommendEvent {
  final ProductModel product;
  final String userId;

  AddToCart(this.product, this.userId);

  @override
  List<Object?> get props => [product, userId];
}

// States
abstract class AIRecommendState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AIRecommendInitial extends AIRecommendState {}

class AIRecommendLoading extends AIRecommendState {}

class AIRecommendLoaded extends AIRecommendState {
  final List<ProductModel> products;
  final Map<String, String> recommendReasons;
  final String? message;

  AIRecommendLoaded(
    this.products, {
    this.recommendReasons = const {},
    this.message,
  });

  @override
  List<Object?> get props => [products, recommendReasons, message];

  String getRecommendReason(String productId) {
    return recommendReasons[productId] ?? '회원님의 취향과 일치하는 상품입니다.';
  }
}

class AIRecommendError extends AIRecommendState {
  final String message;
  final Object? error;

  AIRecommendError(this.message, [this.error]);

  @override
  List<Object?> get props => [message, error];
}

// Bloc
class AIRecommendBloc extends Bloc<AIRecommendEvent, AIRecommendState> {
  final AIRecommendRepository repository;
  final sharedPreference = OnlyYouSharedPreference();

  AIRecommendBloc({required this.repository}) : super(AIRecommendInitial()) {
    on<LoadAIRecommendations>(_onLoadRecommendations);
    on<ToggleProductFavorite>(_onToggleFavorite);
    on<AddToCart>(_onAddToCart);
  }

  Future<void> _onLoadRecommendations(
    LoadAIRecommendations event,
    Emitter<AIRecommendState> emit,
  ) async {
    try {
      print(
          'Loading recommendations for user: ${await sharedPreference.getCurrentUserId()}');
      emit(AIRecommendLoading());

      final userId = await sharedPreference.getCurrentUserId();
      print('Current state: $state');
      print(
          'Products loaded: ${state is AIRecommendLoaded ? (state as AIRecommendLoaded).products.length : 0}');
      if (userId.isEmpty) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final userData = await repository.getUserBehaviorData(userId);
      print('User behavior data: $userData');
      if (userData.isEmpty) {
        emit(AIRecommendLoaded([], message: '추천을 위한 사용자 데이터가 충분하지 않습니다.'));
        return;
      }

      final recommendations = await repository.getAIRecommendations(userData);
      print('AI Recommendations: $recommendations');
      final productIds = List<String>.from(recommendations['products'] ?? []);
      print('Product IDs to fetch: $productIds');

      if (productIds.isEmpty) {
        emit(AIRecommendLoaded([], message: '추천 상품이 없습니다.'));
        return;
      }

      final products = await repository.getRecommendedProducts(productIds);

      emit(AIRecommendLoaded(
        products,
        recommendReasons:
            Map<String, String>.from(recommendations['reasons'] ?? {}),
      ));
    } catch (e) {
      emit(AIRecommendError('추천 상품을 불러오는데 실패했습니다.', e));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleProductFavorite event,
    Emitter<AIRecommendState> emit,
  ) async {
    if (state is! AIRecommendLoaded) return;

    try {
      final currentState = state as AIRecommendLoaded;
      final updatedProducts = currentState.products.map((product) {
        if (product.productId == event.product.productId) {
          final newFavoriteList = List<String>.from(product.favoriteList);
          if (newFavoriteList.contains(event.userId)) {
            newFavoriteList.remove(event.userId);
          } else {
            newFavoriteList.add(event.userId);
          }
          return product.copyWith(favoriteList: newFavoriteList);
        }
        return product;
      }).toList();

      emit(AIRecommendLoaded(
        updatedProducts,
        recommendReasons: currentState.recommendReasons,
      ));

      // TODO: Firestore 업데이트 로직 추가
    } catch (e) {
      emit(AIRecommendError('좋아요 처리 중 오류가 발생했습니다.', e));
    }
  }

  Future<void> _onAddToCart(
    AddToCart event,
    Emitter<AIRecommendState> emit,
  ) async {
    try {
      // TODO: Repository를 통한 장바구니 추가 로직 구현
      // 1. Firestore cart 컬렉션에 상품 추가
      // 2. 로컬 상태 업데이트
    } catch (e) {
      emit(AIRecommendError('장바구니 추가 중 오류가 발생했습니다.', e));
    }
  }
}
