import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/post_model.dart';
import 'package:onlyveyou/screens/shutter/firestore_service.dart';

// Events
abstract class ShutterEvent {}

class FetchPosts extends ShutterEvent {}

class FetchNicknames extends ShutterEvent {
  final List<String> uids;
  FetchNicknames(this.uids);
}

class _UpdatePosts extends ShutterEvent {
  final List<PostModel> posts;
  _UpdatePosts(this.posts);
}

class _FetchError extends ShutterEvent {
  final String message;
  _FetchError(this.message);
}

// State
class ShutterState {
  final List<PostModel> posts;
  final Map<String, String> nicknames;
  final bool isLoading;
  final String? error;

  ShutterState({
    required this.posts,
    this.nicknames = const {},
    this.isLoading = false,
    this.error,
  });

  ShutterState copyWith({
    List<PostModel>? posts,
    Map<String, String>? nicknames,
    bool? isLoading,
    String? error,
  }) {
    return ShutterState(
      posts: posts ?? this.posts,
      nicknames: nicknames ?? this.nicknames,
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
          final uids = posts.map((post) => post.authorUid).toSet().toList();
          add(FetchNicknames(uids));
          add(_UpdatePosts(posts));
        },
        onError: (error) {
          add(_FetchError(error.toString()));
        },
      );
    });

    on<FetchNicknames>((event, emit) async {
      try {
        final nicknames = Map<String, String>.from(state.nicknames);
        for (final uid in event.uids) {
          if (!nicknames.containsKey(uid)) {
            final nickname = await _firestoreService.fetchNickname(uid);
            nicknames[uid] = nickname;
          }
        }
        emit(state.copyWith(nicknames: nicknames));
      } catch (e) {
        print('Error fetching nicknames: $e');
      }
    });

    on<_UpdatePosts>((event, emit) {
      emit(state.copyWith(posts: event.posts, isLoading: false));
    });

    on<_FetchError>((event, emit) {
      emit(state.copyWith(error: event.message, isLoading: false));
    });
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}
