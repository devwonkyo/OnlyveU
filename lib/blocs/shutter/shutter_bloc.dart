import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/post_model.dart';
import 'package:onlyveyou/screens/shutter/firestore_service.dart';

// Events
abstract class ShutterEvent {}

class FetchPosts extends ShutterEvent {}

// State
class ShutterState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? error;

  ShutterState({
    required this.posts,
    this.isLoading = false,
    this.error,
  });

  ShutterState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
  }) {
    return ShutterState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Bloc
class ShutterBloc extends Bloc<ShutterEvent, ShutterState> {
  final FirestoreService _firestoreService;
  StreamSubscription? _postsSubscription;

  ShutterBloc(this._firestoreService)
      : super(ShutterState(posts: [], isLoading: true)) {
    on<FetchPosts>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      await _postsSubscription?.cancel();
      _postsSubscription = _firestoreService.getPosts().listen(
        (posts) {
          add(_UpdatePosts(posts));
        },
        onError: (error) {
          add(_FetchError(error.toString()));
        },
      );
    });

    on<_UpdatePosts>((event, emit) {
      emit(state.copyWith(
        posts: event.posts,
        isLoading: false,
      ));
    });

    on<_FetchError>((event, emit) {
      emit(state.copyWith(
        error: event.message,
        isLoading: false,
      ));
    });
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}

class _UpdatePosts extends ShutterEvent {
  final List<PostModel> posts;
  _UpdatePosts(this.posts);
}

class _FetchError extends ShutterEvent {
  final String message;
  _FetchError(this.message);
}
