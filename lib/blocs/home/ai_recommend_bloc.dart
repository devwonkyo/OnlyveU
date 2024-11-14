import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:onlyveyou/models/product_model.dart';
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
  final String productId;

  AddToCart(this.productId);

  @override
  List<Object?> get props => [productId];
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
  final Map<String, String> recommendReasons; // productId를 key로 사용

  AIRecommendLoaded(this.products, {this.recommendReasons = const {}});

  @override
  List<Object?> get props => [products, recommendReasons];

  // 특정 상품의 추천 이유를 가져오는 헬퍼 메서드
  String getRecommendReason(String productId) {
    return recommendReasons[productId] ?? '회원님 취향과 일치';
  }
}

class AIRecommendError extends AIRecommendState {
  final String message;

  AIRecommendError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AIRecommendBloc extends Bloc<AIRecommendEvent, AIRecommendState> {
  final String openAIApiKey =
      FirebaseRemoteConfig.instance.getString('openai_api_key');
  final sharedPreference = OnlyYouSharedPreference();

  AIRecommendBloc() : super(AIRecommendInitial()) {
    on<LoadAIRecommendations>(_onLoadRecommendations);
    on<ToggleProductFavorite>(_onToggleFavorite);
    on<AddToCart>(_onAddToCart);
  }

  Future<void> _onLoadRecommendations(
    LoadAIRecommendations event,
    Emitter<AIRecommendState> emit,
  ) async {
    try {
      emit(AIRecommendLoading());

      final userId = await sharedPreference.getCurrentUserId();

      // 임시 데이터
      final userData = {
        'viewHistory': ['product1', 'product2'],
        'likedItems': ['product3'],
        'cartItems': ['product4']
      };

      // AI 추천 받기
      final recommendations = await _getAIRecommendationsWithReasons(userData);

      // TODO: Firestore에서 추천된 상품들의 정보를 가져오기
      final List<ProductModel> recommendedProducts = [];

      emit(AIRecommendLoaded(recommendedProducts,
          recommendReasons: recommendations['reasons'] as Map<String, String>));
    } catch (e) {
      emit(AIRecommendError('추천 상품을 불러오는데 실패했습니다. 다시 시도해주세요.'));
    }
  }

  Future<Map<String, dynamic>> _getAIRecommendationsWithReasons(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  '당신은 e-commerce 추천 시스템입니다. 사용자의 행동 데이터를 기반으로 상품을 추천하고 추천 이유도 제공해주세요.'
            },
            {
              'role': 'user',
              'content': '''
                사용자의 행동 데이터:
                최근 본 상품: ${userData['viewHistory'].join(', ')}
                좋아요한 상품: ${userData['likedItems'].join(', ')}
                장바구니 상품: ${userData['cartItems'].join(', ')}
                
                이 사용자에게 적합한 상품 10개를 추천해주시고, 각 상품별로 추천 이유도 함께 알려주세요.
                다음 기준을 고려해주세요:
                1. 카테고리 선호도
                2. 가격대 선호도
                3. 브랜드 선호도
                4. 스타일 패턴
                
                응답 형식:
                {
                  "products": ["product_id1", "product_id2", ...],
                  "reasons": {
                    "product_id1": "추천 이유 1",
                    "product_id2": "추천 이유 2",
                    ...
                  }
                }
              '''
            }
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        final recommendData = jsonDecode(content);

        return {
          'products': recommendData['products'] as List<String>,
          'reasons': recommendData['reasons'] as Map<String, String>,
        };
      } else {
        throw Exception('Failed to get AI recommendations');
      }
    } catch (e) {
      throw Exception('AI 추천 시스템 오류: $e');
    }
  }

  Future<void> _onToggleFavorite(
    ToggleProductFavorite event,
    Emitter<AIRecommendState> emit,
  ) async {
    try {
      if (state is AIRecommendLoaded) {
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

        emit(AIRecommendLoaded(updatedProducts,
            recommendReasons: currentState.recommendReasons));
      }
    } catch (e) {
      // 에러 발생 시 현재 상태 유지
    }
  }

  Future<void> _onAddToCart(
    AddToCart event,
    Emitter<AIRecommendState> emit,
  ) async {
    try {
      // TODO: 장바구니 추가 로직 구현
    } catch (e) {
      // 에러 발생 시 현재 상태 유지
    }
  }
}
