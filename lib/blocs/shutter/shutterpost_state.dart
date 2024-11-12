import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

class PostState extends Equatable {
  final String text;
  final List<XFile> images;
  final List<String> tags;

  const PostState({
    required this.text,
    required this.images,
    required this.tags,
  });

  factory PostState.initial() {
    return const PostState(
      text: '',
      images: [],
      tags: [],
    );
  }

  PostState copyWith({
    String? text,
    List<XFile>? images,
    List<String>? tags,
  }) {
    return PostState(
      text: text ?? this.text,
      images: images ?? this.images,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [text, images, tags];
}
