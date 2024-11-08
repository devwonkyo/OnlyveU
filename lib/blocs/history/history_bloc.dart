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
        await _historyRepository.toggleFavorite(
          event.product.productId,
          event.userId,
        ); //^

        add(LoadHistoryItems()); // 상태 새로고침
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
        ); //^

        add(LoadHistoryItems());
      } catch (e) {
        print('Error removing history item: $e');
      }
    });

    on<ClearHistory>((event, emit) async {
      //^
      try {
        if (state is HistoryState) {
          final currentState = state;
          final userId = await _prefs.getCurrentUserId();

          // 좋아요한 상품들 전체 삭제 처리
          for (var product in currentState.favoriteItems) {
            await _historyRepository.toggleFavorite(
              //^ toggleFavorite로 변경
              product.productId,
              userId,
            );
          }

          emit(HistoryState(
            recentItems: currentState.recentItems,
            favoriteItems: [], // 좋아요 목록 비우기
          ));
        }
      } catch (e) {
        print('Error clearing history: $e');
      }
    }); //^
  }
}

///태그 데이터 뿌려주는작업?
