import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/history_repository.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

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

class AddToCart extends HistoryEvent {
  final String productId;
  AddToCart(this.productId);
}

abstract class HistoryState {
  final List<ProductModel> recentItems;
  final List<ProductModel> favoriteItems;

  const HistoryState({
    required this.recentItems,
    required this.favoriteItems,
  });
}

class HistoryInitial extends HistoryState {
  HistoryInitial() : super(recentItems: [], favoriteItems: []);
}

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

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _historyRepository;
  final ShoppingCartRepository _cartRepository;
  final _prefs = OnlyYouSharedPreference();
  StreamSubscription? _historySubscription;

  HistoryBloc({
    required HistoryRepository historyRepository,
    required ShoppingCartRepository cartRepository,
  })  : _historyRepository = historyRepository,
        _cartRepository = cartRepository,
        super(HistoryInitial()) {
    on<LoadHistoryItems>((event, emit) async {
      if (state is! HistoryInitial) return;

      try {
        await _historySubscription?.cancel();

        await emit.forEach(
          _historyRepository.fetchHistoryAndLikedItems(),
          onData: (HistoryData data) {
            return HistoryLoaded(
              recentItems: data.recentItems,
              favoriteItems: data.likedItems,
            );
          },
        );
      } catch (e) {
        print('Error loading history items: $e');
      }
    });

    on<ToggleFavorite>((event, emit) async {
      try {
        await _historyRepository.toggleFavorite(
          event.product.productId,
          event.userId,
        );
      } catch (e) {
        print('Error toggling favorite: $e');
      }
    });

    on<RemoveHistoryItem>((event, emit) async {
      try {
        final userId = await _prefs.getCurrentUserId();
        await _historyRepository.removeHistoryItem(
          event.product.productId,
          userId,
        );
      } catch (e) {
        print('Error removing history item: $e');
      }
    });

    on<ClearHistory>((event, emit) async {
      try {
        final userId = await _prefs.getCurrentUserId();
        await _historyRepository.clearHistory(userId);
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
          message: '장바구니에 담겼습니다.',
        ));
      } catch (e) {
        emit(HistorySuccess(
          recentItems: state.recentItems,
          favoriteItems: state.favoriteItems,
          message: e.toString(),
        ));
      }
    });
  }

  @override
  Future<void> close() async {
    await _historySubscription?.cancel();
    return super.close();
  }
}
