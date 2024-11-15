// shutterpost_state.dart
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

class PostState extends Equatable {
  final String title;
  final String text;
  final List<XFile> images;
  final List<String> tags;
  final bool isLoading;

  const PostState({
    required this.title,
    required this.text,
    required this.images,
    required this.tags,
    this.isLoading = false,
  });

  factory PostState.initial() {
    return const PostState(
      title: '',
      text: '',
      images: [],
      tags: [],
    );
  }

  PostState copyWith({
    String? title,
    String? text,
    List<XFile>? images,
    List<String>? tags,
    bool? isLoading,
  }) {
    return PostState(
      title: title ?? this.title,
      text: text ?? this.text,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [title, text, images, tags, isLoading];
}
