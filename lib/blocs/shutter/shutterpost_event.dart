// shutterpost_event.dart
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class AddImageEvent extends PostEvent {
  final XFile image;

  const AddImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class UpdateTextEvent extends PostEvent {
  final String text;

  const UpdateTextEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class ToggleLikeEvent extends PostEvent {
  final String postId;
  final String userId;

  ToggleLikeEvent({required this.postId, required this.userId});
}

class UpdateTagsEvent extends PostEvent {
  final List<String> tags;

  const UpdateTagsEvent(this.tags);

  @override
  List<Object?> get props => [tags];
}

class SubmitPostEvent extends PostEvent {
  final String text;
  final List<XFile> images;
  final List<String> tags;

  const SubmitPostEvent({
    required this.text,
    required this.images,
    required this.tags,
  });

  @override
  List<Object?> get props => [text, images, tags];
}
