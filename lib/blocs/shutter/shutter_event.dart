import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/post_model.dart';

abstract class ShutterEvent extends Equatable {
  const ShutterEvent();

  @override
  List<Object?> get props => [];
}

class FetchPosts extends ShutterEvent {}

class UpdatePosts extends ShutterEvent {
  final List<PostModel> posts;

  const UpdatePosts(this.posts);

  @override
  List<Object?> get props => [posts];
}

class FetchError extends ShutterEvent {
  final String error;

  const FetchError(this.error);

  @override
  List<Object?> get props => [error];
}

class TagSelected extends ShutterEvent {
  final String tag;

  const TagSelected(this.tag);

  @override
  List<Object?> get props => [tag];
}
