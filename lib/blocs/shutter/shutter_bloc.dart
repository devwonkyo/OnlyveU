import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/shutter/shutter_event.dart';
import 'package:onlyveyou/blocs/shutter/shutter_state.dart';
import 'package:onlyveyou/models/post_model.dart';
import 'package:onlyveyou/screens/shutter/firestore_service.dart';

class ShutterBloc extends Bloc<ShutterEvent, ShutterState> {
  final FirestoreService _firestoreService;
  StreamSubscription? _postsSubscription;

  ShutterBloc(this._firestoreService) : super(const ShutterState()) {
    // FetchPosts 이벤트 처리
    on<FetchPosts>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null)); // 로딩 상태로 설정

      // Firestore 구독 취소 후 새로 시작
      await _postsSubscription?.cancel();
      _postsSubscription = _firestoreService.getPosts().listen(
        (posts) {
          add(UpdatePosts(posts)); // 게시물 업데이트 이벤트 추가
        },
        onError: (error) {
          add(FetchError(error.toString())); // 에러 발생 시 처리
        },
      );
    });

    // UpdatePosts 이벤트 처리
    on<UpdatePosts>((event, emit) {
      emit(state.copyWith(posts: event.posts, isLoading: false, error: null));
    });

    // FetchError 이벤트 처리
    on<FetchError>((event, emit) {
      emit(state.copyWith(isLoading: false, error: event.error));
    });

    // TagSelected 이벤트 처리
    on<TagSelected>((event, emit) {
      emit(state.copyWith(selectedTag: event.tag, error: null));
    });
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel(); // Firestore 구독 취소
    return super.close();
  }
}
