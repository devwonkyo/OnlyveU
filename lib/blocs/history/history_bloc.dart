import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

import '../../models/history_item.dart';
import '../../models/product_model.dart'; // ProductModel을 임포트
import '../../repositories/history_repository.dart';

// 1. 이벤트 정의 - 앱에서 발생할 수 있는 모든 액션들
abstract class HistoryEvent {}

// Firestore에서 히스토리 아이템을 불러오는 이벤트
class LoadHistoryItems extends HistoryEvent {}

// 특정 히스토리 아이템을 삭제하는 이벤트
class RemoveHistoryItem extends HistoryEvent {
  final HistoryItem item; // 삭제할 아이템을 전달받음
  RemoveHistoryItem(this.item); // 생성자에서 삭제할 아이템 설정
}

// 좋아요 상태를 변경하는 이벤트
class ToggleFavorite extends HistoryEvent {
  final HistoryItem item; // 좋아요 상태를 변경할 아이템을 전달받음
  ToggleFavorite(this.item); // 생성자에서 해당 아이템 설정
}

// 모든 히스토리 아이템을 삭제하는 이벤트
class ClearHistory extends HistoryEvent {}

// 2. 상태 정의 - 앱의 데이터 상태를 나타내는 클래스
class HistoryState {
  final List<HistoryItem> recentItems; // 최근 본 아이템 리스트
  final List<HistoryItem> favoriteItems; // 좋아요한 아이템 리스트

  HistoryState({
    required this.recentItems,
    required this.favoriteItems,
  });
}

// 3. BLoC 구현 - 이벤트를 받아서 상태를 변경하는 로직
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _prefs = OnlyYouSharedPreference(); // Firebase와의 연동을 위한 repository

  // BLoC 생성자
  HistoryBloc({required HistoryRepository repository})
      : _repository = repository, // repository 초기화
        super(HistoryState(recentItems: [], favoriteItems: [])) {
    // 기본 상태 설정

    // 3.1 LoadHistoryItems 이벤트를 처리하여 Firestore에서 데이터 불러오기
    on<LoadHistoryItems>((event, emit) async {
      try {
        // Firestore에서 데이터를 불러와 최근 본 아이템 리스트 생성
        final recentItems = await _repository.fetchHistoryItems();
        // 좋아요가 설정된 아이템만 필터링하여 좋아요 리스트 생성
        final favoriteItems =
            recentItems.where((item) => item.isFavorite).toList();
        // 새로운 상태로 emit하여 recentItems와 favoriteItems 업데이트
        emit(HistoryState(
            recentItems: recentItems, favoriteItems: favoriteItems));
      } catch (e) {
        // 에러 발생 시 콘솔에 출력하고 상태를 유지
        print('Error loading history items: $e');
        emit(state); // 에러가 발생하면 기존 상태 유지
      }
    });

    // 3.2 RemoveHistoryItem 이벤트를 처리하여 특정 아이템 삭제
    on<RemoveHistoryItem>((event, emit) {
      // recentItems 리스트에서 해당 아이템을 제외한 새로운 리스트 생성
      final updatedRecentItems =
          state.recentItems.where((item) => item.id != event.item.id).toList();
      // favoriteItems 리스트에서도 해당 아이템을 제외한 새로운 리스트 생성
      final updatedFavoriteItems = state.favoriteItems
          .where((item) => item.id != event.item.id)
          .toList();
      // 새로운 상태로 emit하여 삭제 후의 리스트로 업데이트
      emit(HistoryState(
          recentItems: updatedRecentItems,
          favoriteItems: updatedFavoriteItems));
    });

    // 3.3 ToggleFavorite 이벤트 핸들러 수정
    on<ToggleFavorite>((event, emit) async {
      try {
        // 현재 사용자 ID 가져오기
        final userId = await _prefs.getCurrentUserId();

        // Firestore에서 해당 상품 문서 가져오기
        final docRef = _firestore.collection('products').doc(event.item.id);
        final doc = await docRef.get();

        if (doc.exists) {
          // Firestore 문서에서 ProductModel 객체 생성
          final product =
              ProductModel.fromMap(doc.data() as Map<String, dynamic>);
          List<String> updatedFavoriteList =
              List<String>.from(product.favoriteList);

          // 좋아요 목록 업데이트
          if (updatedFavoriteList.contains(userId)) {
            updatedFavoriteList.remove(userId);
          } else {
            updatedFavoriteList.add(userId);
          }

          // Firestore 업데이트
          await docRef.update({'favoriteList': updatedFavoriteList});

          // 로컬 상태 업데이트
          final updatedRecentItems = state.recentItems.map((item) {
            if (item.id == event.item.id) {
              return item.copyWith(isFavorite: !item.isFavorite);
            }
            return item;
          }).toList();

          // 좋아요 상태가 true인 아이템만 필터링하여 좋아요 리스트 생성
          final updatedFavoriteItems =
              updatedRecentItems.where((item) => item.isFavorite).toList();

          // 새로운 상태로 emit하여 좋아요 상태 변경
          emit(HistoryState(
            recentItems: updatedRecentItems,
            favoriteItems: updatedFavoriteItems,
          ));
        }
      } catch (e) {
        print('Error toggling favorite: $e');
      }
    });

    // 3.4 ClearHistory 이벤트를 처리하여 모든 히스토리 삭제
    on<ClearHistory>((event, emit) {
      // 빈 리스트로 상태 초기화하여 모든 아이템 삭제
      emit(HistoryState(recentItems: [], favoriteItems: []));
    });
  }
}
