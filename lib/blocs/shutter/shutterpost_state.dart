// post_state.dart
import 'package:image_picker/image_picker.dart';

enum PostStatus { initial, submitting, success, failure }

class PostState {
  final List<XFile> images;
  final List<String> imageUrls; // 이미지 URLs 리스트
  final String text;
  final PostStatus postStatus;

  PostState({
    this.images = const [],
    this.imageUrls = const [],
    this.text = '',
    this.postStatus = PostStatus.initial,
  });

  PostState copyWith({
    List<XFile>? images,
    List<String>? imageUrls,
    String? text,
    PostStatus? postStatus,
  }) {
    return PostState(
      images: images ?? this.images,
      imageUrls: imageUrls ?? this.imageUrls,
      text: text ?? this.text,
      postStatus: postStatus ?? this.postStatus,
    );
  }
}
