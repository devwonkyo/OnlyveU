// blocs/history/history_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/history_item.dart';
import '../../screens/history/widgets/dummy_history.dart';

// 1. 이벤트 정의 - 앱에서 발생할 수 있는 모든 액션들
abstract class HistoryEvent {}

// 히스토리 아이템들을 불러오는 이벤트
class LoadHistoryItems extends HistoryEvent {}

// 특정 아이템을 삭제하는 이벤트
class RemoveHistoryItem extends HistoryEvent {
  final HistoryItem item; // 삭제할 아이템
  RemoveHistoryItem(this.item);
}

// 좋아요 상태를 변경하는 이벤트
class ToggleFavorite extends HistoryEvent {
  final HistoryItem item; // 좋아요 상태를 변경할 아이템
  ToggleFavorite(this.item);
}

// 모든 히스토리를 삭제하는 이벤트
class ClearHistory extends HistoryEvent {}

// 2. 상태 정의 - 앱의 데이터 상태
class HistoryState {
  final List<HistoryItem> recentItems; // 최근 본 아이템들
  final List<HistoryItem> favoriteItems; // 좋아요한 아이템들

  HistoryState({
    required this.recentItems,
    required this.favoriteItems,
  });
}

// 3. BLoC 구현 - 이벤트를 받아서 상태를 변경하는 로직
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  // 초기 상태로 빈 리스트들을 설정
  HistoryBloc() : super(HistoryState(recentItems: [], favoriteItems: [])) {
    // 3.1 히스토리 아이템 로드 처리
    on<LoadHistoryItems>((event, emit) {
      // 더미 데이터로부터 아이템들을 복사
      final recentItems = List<HistoryItem>.from(dummyHistoryItems);
      // 좋아요된 아이템들만 필터링
      final favoriteItems =
          dummyHistoryItems.where((item) => item.isFavorite).toList();
      // 새로운 상태 발행
      emit(
          HistoryState(recentItems: recentItems, favoriteItems: favoriteItems));
    });

    // 3.2 아이템 삭제 처리
    on<RemoveHistoryItem>((event, emit) {
      // 삭제할 아이템을 제외한 새 리스트 생성
      final updatedRecentItems =
          state.recentItems.where((item) => item.id != event.item.id).toList();
      final updatedFavoriteItems = state.favoriteItems
          .where((item) => item.id != event.item.id)
          .toList();
      // 새로운 상태 발행
      emit(HistoryState(
          recentItems: updatedRecentItems,
          favoriteItems: updatedFavoriteItems));
    });

    // 3.3 좋아요 토글 처리
    on<ToggleFavorite>((event, emit) {
      // 모든 아이템을 순회하며 해당 아이템의 좋아요 상태 변경
      final updatedRecentItems = state.recentItems.map((item) {
        if (item.id == event.item.id) {
          // 같은 ID를 가진 아이템을 찾아 좋아요 상태만 반전
          return HistoryItem(
            id: item.id,
            title: item.title,
            imageUrl: item.imageUrl,
            price: item.price,
            originalPrice: item.originalPrice,
            discountRate: item.discountRate,
            isBest: item.isBest,
            isFavorite: !item.isFavorite, // 좋아요 상태 토글
          );
        }
        return item;
      }).toList();

      // 업데이트된 목록에서 좋아요된 아이템들만 필터링
      final updatedFavoriteItems =
          updatedRecentItems.where((item) => item.isFavorite).toList();

      // 새로운 상태 발행
      emit(HistoryState(
          recentItems: updatedRecentItems,
          favoriteItems: updatedFavoriteItems));
    });

    // 3.4 모든 히스토리 삭제 처리
    on<ClearHistory>((event, emit) {
      // 빈 리스트로 상태 초기화
      emit(HistoryState(recentItems: [], favoriteItems: []));
    });
  }
}
