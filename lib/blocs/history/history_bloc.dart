import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/history_repository.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

// Events
abstract class HistoryEvent {}

class LoadHistoryItems extends HistoryEvent {}

class RemoveHistoryItem extends HistoryEvent {
  final ProductModel product;
  RemoveHistoryItem(this.product);
}

class ToggleFavorite extends HistoryEvent {
  final ProductModel product;
  final String userId;
  ToggleFavorite(this.product, this.userId);
}

class ClearHistory extends HistoryEvent {}

//장바구니 담기
class AddToCart extends HistoryEvent {
  final String productId;
  AddToCart(this.productId);
}

// State
abstract class HistoryState {
  // HistoryState를 한 번만 정의
  final List<ProductModel> recentItems;
  final List<ProductModel> favoriteItems;

  const HistoryState({
    required this.recentItems,
    required this.favoriteItems,
  });
}

// 기본 상태 클래스 추가
class HistoryInitial extends HistoryState {
  HistoryInitial() : super(recentItems: [], favoriteItems: []);
}

// 로드된 상태 클래스 추가
class HistoryLoaded extends HistoryState {
  const HistoryLoaded({
    required List<ProductModel> recentItems,
    required List<ProductModel> favoriteItems,
  }) : super(recentItems: recentItems, favoriteItems: favoriteItems);
}

class HistorySuccess extends HistoryState {
  final String message;

  const HistorySuccess({
    required List<ProductModel> recentItems,
    required List<ProductModel> favoriteItems,
    required this.message,
  }) : super(recentItems: recentItems, favoriteItems: favoriteItems);
}

// Bloc
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _historyRepository;
  final ShoppingCartRepository _cartRepository;
  final _prefs = OnlyYouSharedPreference();
  StreamSubscription? _historySubscription; // 스트림 구독을 위한 변수 추가

  HistoryBloc({
    required HistoryRepository historyRepository,
    required ShoppingCartRepository cartRepository,
  })  : _historyRepository = historyRepository,
        _cartRepository = cartRepository,
        super(HistoryInitial()) {
    on<LoadHistoryItems>((event, emit) async {
      if (state is! HistoryInitial) return; // 이미 로드됐으면 스킵

      try {
        final userId = await _prefs.getCurrentUserId();
        await _historySubscription?.cancel();

        await emit.forEach(
          _historyRepository.fetchHistoryItems().distinct(), // 중복 제거
          onData: (List<ProductModel> items) {
            final favoriteItems = items
                .where((product) => product.favoriteList.contains(userId))
                .toList();

            return HistoryLoaded(
              recentItems: items,
              favoriteItems: favoriteItems,
            );
          },
        );
      } catch (e) {
        print('Error loading history items: $e');
      }
    });

    // 나머지 이벤트 핸들러들은 그대로 유지
    on<ToggleFavorite>((event, emit) async {
      try {
        await _historyRepository.toggleFavorite(
          event.product.productId,
          event.userId,
        );
        // 상태는 스트림을 통해 자동으로 업데이트됨
      } catch (e) {
        print('Error toggling favorite: $e');
      }
    });

    on<RemoveHistoryItem>((event, emit) async {
      try {
        final userId = await _prefs.getCurrentUserId();
        await _historyRepository.toggleFavorite(
          event.product.productId,
          userId,
        );
        // 상태는 스트림을 통해 자동으로 업데이트됨
      } catch (e) {
        print('Error removing history item: $e');
      }
    });

    on<ClearHistory>((event, emit) async {
      try {
        if (state is HistoryState) {
          final currentState = state;
          final userId = await _prefs.getCurrentUserId();

          for (var product in currentState.favoriteItems) {
            await _historyRepository.toggleFavorite(
              product.productId,
              userId,
            );
          }
        }
      } catch (e) {
        print('Error clearing history: $e');
      }
    });

    on<AddToCart>((event, emit) async {
      try {
        await _cartRepository.addToCart(event.productId);
        emit(HistorySuccess(
            recentItems: state.recentItems,
            favoriteItems: state.favoriteItems,
            message: '장바구니에 담겼습니다.'));
      } catch (e) {
        emit(HistorySuccess(
            recentItems: state.recentItems,
            favoriteItems: state.favoriteItems,
            message: e.toString()));
      }
    });
  }

  // 메모리 누수 방지를 위해 dispose 추가
  @override
  Future<void> close() async {
    await _historySubscription?.cancel();
    return super.close();
  }
}

///태그 데이터 뿌려주는작업?
