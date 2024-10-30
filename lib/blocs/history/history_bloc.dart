// blocs/history/history_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/history_item.dart';
import '../../screens/history/widgets/dummy_history.dart';

// Events
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

// State
class HistoryState {
  final List<HistoryItem> recentItems;
  final List<HistoryItem> favoriteItems;

  HistoryState({
    required this.recentItems,
    required this.favoriteItems,
  });
}

// Bloc
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryState(recentItems: [], favoriteItems: [])) {
    on<LoadHistoryItems>((event, emit) {
      final recentItems = List<HistoryItem>.from(dummyHistoryItems);
      final favoriteItems =
          dummyHistoryItems.where((item) => item.isFavorite).toList();
      emit(
          HistoryState(recentItems: recentItems, favoriteItems: favoriteItems));
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
          return HistoryItem(
            id: item.id,
            title: item.title,
            imageUrl: item.imageUrl,
            price: item.price,
            originalPrice: item.originalPrice,
            discountRate: item.discountRate,
            isBest: item.isBest,
            isFavorite: !item.isFavorite,
          );
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
