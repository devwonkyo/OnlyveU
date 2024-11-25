import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/comment_model.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final FirebaseFirestore firestore;

  CommentBloc({required this.firestore}) : super(CommentLoadingState()) {
    on<LoadCommentsEvent>(_onLoadComments);
    on<AddCommentEvent>(_onAddComment);
  }

  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<CommentState> emit,
  ) async {
    try {
      emit(CommentLoadingState());

      final snapshot = await firestore
          .collection('comments')
          .where('postId', isEqualTo: event.postId)
          .orderBy('createdAt', descending: true)
          .get();

      final comments = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Add document ID to the data map
        data['id'] = doc.id;
        return CommentModel.fromMap(data);
      }).toList();

      emit(CommentLoadedState(comments));
    } catch (e) {
      emit(CommentErrorState('Failed to load comments: $e'));
    }
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    try {
      final commentData = CommentModel(
        id: '', // Firestore will generate this
        postId: event.postId,
        authorUid: event.authorUid,
        authorName: event.authorName,
        text: event.text,
        createdAt: DateTime.now(),
      );

      // Add the comment and get the reference
      final docRef =
          await firestore.collection('comments').add(commentData.toMap());

      // Reload comments after adding
      add(LoadCommentsEvent(postId: event.postId));
    } catch (e) {
      emit(CommentErrorState('Failed to add comment: $e'));
    }
  }
}
