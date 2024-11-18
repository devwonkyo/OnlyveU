import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/post_model.dart';

class ShutterState extends Equatable {
  final List<PostModel> posts; // 게시물 리스트
  final String? selectedTag; // 선택된 태그
  final bool isLoading; // 로딩 중인지 여부
  final String? error; // 에러 메시지 (null일 경우 에러 없음)

  const ShutterState({
    this.posts = const [],
    this.selectedTag,
    this.isLoading = false,
    this.error,
  });

  // 상태 복사 메서드
  ShutterState copyWith({
    List<PostModel>? posts,
    String? selectedTag,
    bool? isLoading,
    String? error,
  }) {
    return ShutterState(
      posts: posts ?? this.posts,
      selectedTag: selectedTag ?? this.selectedTag,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [posts, selectedTag, isLoading, error];
}
