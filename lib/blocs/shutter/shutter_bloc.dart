import 'package:flutter_bloc/flutter_bloc.dart';
import 'shutter_event.dart';
import 'shutter_state.dart';
import 'package:onlyveyou/screens/shutter/firestore_service.dart';

class ShutterBloc extends Bloc<ShutterEvent, ShutterState> {
  final FirestoreService _firestoreService;

  ShutterBloc(this._firestoreService) : super(ShutterState()) {
    // FetchPosts 이벤트에 대한 핸들러를 on 메서드를 통해 등록
    on<FetchPosts>((event, emit) async {
      try {
        final posts = await _firestoreService.fetchPosts();
        emit(state.copyWith(posts: posts));
      } catch (e) {
        // 에러 상태 처리
      }
    });

    // TagSelected 이벤트에 대한 핸들러 추가 (선택된 태그 업데이트)
    on<TagSelected>((event, emit) {
      emit(state.copyWith(selectedTag: event.tag));
    });
  }
}
