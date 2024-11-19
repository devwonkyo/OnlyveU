import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:onlyveyou/models/comment_model.dart';
import 'package:onlyveyou/blocs/shutter/comment_bloc.dart';
import 'package:onlyveyou/models/post_model.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<DocumentSnapshot> _postStream;
  late CommentBloc _commentBloc;

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  void initState() {
    super.initState();
    _postStream =
        _firestore.collection('posts').doc(widget.post.id).snapshots();
    _commentBloc = CommentBloc(firestore: FirebaseFirestore.instance)
      ..add(LoadCommentsEvent(postId: widget.post.id));
  }

  Future<void> _toggleLike() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final postRef = _firestore.collection('posts').doc(widget.post.id);

    try {
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) return;

        List<String> likedBy = List<String>.from(postDoc.get('likedBy') ?? []);
        int currentLikes = postDoc.get('likes') ?? 0;

        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
          currentLikes -= 1;
        } else {
          likedBy.add(userId);
          currentLikes += 1;
        }

        transaction.update(postRef, {
          'likedBy': likedBy,
          'likes': currentLikes,
        });
      });
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  void _addComment() {
    final user = _auth.currentUser;
    if (user != null && _commentController.text.isNotEmpty) {
      _commentBloc.add(AddCommentEvent(
        postId: widget.post.id,
        authorUid: user.uid,
        authorName: user.displayName ?? 'Unknown',
        text: _commentController.text,
      ));
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _commentBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.post.authorName),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.imageUrls.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 300,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: false,
                        ),
                        items: widget.post.imageUrls.map((url) {
                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        }).toList(),
                      ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: _postStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          );
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final likes = data['likes'] ?? 0;
                        final likedBy =
                            List<String>.from(data['likedBy'] ?? []);
                        final isLiked =
                            likedBy.contains(_auth.currentUser?.uid);

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : null,
                                ),
                                onPressed: _toggleLike,
                              ),
                              Text('$likes likes'),
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.text,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatDate(widget.post.createdAt),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    BlocBuilder<CommentBloc, CommentState>(
                      builder: (context, state) {
                        if (state is CommentLoadingState) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is CommentLoadedState) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.comments.length,
                            itemBuilder: (context, index) {
                              final comment = state.comments[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(comment.authorName[0]),
                                ),
                                title: Row(
                                  children: [
                                    Text(comment.authorName),
                                    const SizedBox(width: 8),
                                    Text(
                                      formatDate(comment.createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(comment.text),
                              );
                            },
                          );
                        } else if (state is CommentErrorState) {
                          return Center(child: Text(state.error));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentBloc.close();
    super.dispose();
  }
}
