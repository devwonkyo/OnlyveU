import 'package:onlyveyou/models/post_model.dart';

class ShutterState {
  final List<PostModel> posts;
  final String? selectedTag;

  ShutterState({this.posts = const [], this.selectedTag});

  ShutterState copyWith({List<PostModel>? posts, String? selectedTag}) {
    return ShutterState(
      posts: posts ?? this.posts,
      selectedTag: selectedTag ?? this.selectedTag,
    );
  }
}
