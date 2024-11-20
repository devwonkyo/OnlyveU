part of 'comment_bloc.dart';

abstract class CommentEvent {}

class LoadCommentsEvent extends CommentEvent {
  final String postId;

  LoadCommentsEvent({required this.postId});
}

class AddCommentEvent extends CommentEvent {
  final String postId;
  final String authorUid;
  final String authorName;
  final String text;

  AddCommentEvent({
    required this.postId,
    required this.authorUid,
    required this.authorName,
    required this.text,
  });
}
