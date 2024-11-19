part of 'comment_bloc.dart';

abstract class CommentState {}

class CommentLoadingState extends CommentState {}

class CommentLoadedState extends CommentState {
  final List<CommentModel> comments;

  CommentLoadedState(this.comments);
}

class CommentErrorState extends CommentState {
  final String error;

  CommentErrorState(this.error);
}
