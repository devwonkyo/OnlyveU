import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/history_repository.dart';
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

// State
class HistoryState {
  final List<ProductModel> recentItems;
  final List<ProductModel> favoriteItems;

  HistoryState({
    required this.recentItems,
    required this.favoriteItems,
  });
}

// Bloc
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _historyRepository;
  final _prefs = OnlyYouSharedPreference();

  HistoryBloc(
      {required HistoryRepository
          historyRepository}) // 매개변수명을 historyRepository로 변경
      : _historyRepository = historyRepository,
        super(HistoryState(recentItems: [], favoriteItems: [])) {
    on<LoadHistoryItems>((event, emit) async {
      try {
        final userId = await _prefs.getCurrentUserId();
        final allItems = await _historyRepository.fetchHistoryItems();

        final favoriteItems = allItems
            .where((product) => product.favoriteList.contains(userId))
            .toList();

        emit(HistoryState(
          recentItems: allItems,
          favoriteItems: favoriteItems,
        ));
      } catch (e) {
        print('Error loading history items: $e');
      }
    });

    on<ToggleFavorite>((event, emit) async {
      try {
        List<String> updatedFavoriteList =
            List<String>.from(event.product.favoriteList);

        if (updatedFavoriteList.contains(event.userId)) {
          updatedFavoriteList.remove(event.userId);
        } else {
          updatedFavoriteList.add(event.userId);
        }

        await _historyRepository.toggleFavorite(
          event.product.productId,
          updatedFavoriteList,
        );

        add(LoadHistoryItems());
      } catch (e) {
        print('Error toggling favorite: $e');
      }
    });

    on<RemoveHistoryItem>((event, emit) {
      final currentState = state;
      emit(HistoryState(
        recentItems: currentState.recentItems
            .where((item) => item.productId != event.product.productId)
            .toList(),
        favoriteItems: currentState.favoriteItems
            .where((item) => item.productId != event.product.productId)
            .toList(),
      ));
    });

    on<ClearHistory>((event, emit) {
      emit(HistoryState(recentItems: [], favoriteItems: []));
    });
  }
}
