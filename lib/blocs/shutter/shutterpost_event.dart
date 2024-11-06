import 'package:image_picker/image_picker.dart';

abstract class PostEvent {}

class AddImageEvent extends PostEvent {
  final XFile image;

  AddImageEvent(this.image);
}

class RemoveImageEvent extends PostEvent {
  final int index;

  RemoveImageEvent(this.index);
}

class UpdateTextEvent extends PostEvent {
  final String text;

  UpdateTextEvent(this.text);
}

class SubmitPostEvent extends PostEvent {
  final String text;
  final List<XFile> images;
  final List<String> tags;

  SubmitPostEvent({
    required this.text,
    required this.images,
    required this.tags,
  });
}
