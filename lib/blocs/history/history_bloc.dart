import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/history_item.dart';
import '../../repositories/history_repository.dart';

// 1. 이벤트 정의 - 앱에서 발생할 수 있는 모든 액션들
abstract class HistoryEvent {}

class LoadHistoryItems extends HistoryEvent {}

class RemoveHistoryItem extends HistoryEvent {
  final HistoryItem item;
  RemoveHistoryItem(this.item);
}

class ToggleFavorite extends HistoryEvent {
  final HistoryItem item;
  ToggleFavorite(this.item);
}

class ClearHistory extends HistoryEvent {}

// 2. 상태 정의 - 앱의 데이터 상태
class HistoryState {
  final List<HistoryItem> recentItems;
  final List<HistoryItem> favoriteItems;

  HistoryState({
    required this.recentItems,
    required this.favoriteItems,
  });
}

// 3. BLoC 구현 - 이벤트를 받아서 상태를 변경하는 로직
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _repository;

  HistoryBloc({required HistoryRepository repository})
      : _repository = repository,
        super(HistoryState(recentItems: [], favoriteItems: [])) {
    on<LoadHistoryItems>((event, emit) async {
      try {
        final recentItems = await _repository.fetchHistoryItems();
        final favoriteItems =
            recentItems.where((item) => item.isFavorite).toList();
        emit(HistoryState(
            recentItems: recentItems, favoriteItems: favoriteItems));
      } catch (e) {
        print('Error loading history items: $e');
        emit(state);
      }
    });

    on<RemoveHistoryItem>((event, emit) {
      final updatedRecentItems =
          state.recentItems.where((item) => item.id != event.item.id).toList();
      final updatedFavoriteItems = state.favoriteItems
          .where((item) => item.id != event.item.id)
          .toList();
      emit(HistoryState(
          recentItems: updatedRecentItems,
          favoriteItems: updatedFavoriteItems));
    });

    on<ToggleFavorite>((event, emit) {
      final updatedRecentItems = state.recentItems.map((item) {
        if (item.id == event.item.id) {
          return item.copyWith(isFavorite: !item.isFavorite);
        }
        return item;
      }).toList();

      final updatedFavoriteItems =
          updatedRecentItems.where((item) => item.isFavorite).toList();
      emit(HistoryState(
          recentItems: updatedRecentItems,
          favoriteItems: updatedFavoriteItems));
    });

    on<ClearHistory>((event, emit) {
      emit(HistoryState(recentItems: [], favoriteItems: []));
    });
  }
}
