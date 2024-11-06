// post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class PostModel {
  final String text;
  final List<String> imageUrls; // 이미지 URLs 리스트
  final List<String> tags; // 태그 리스트

  PostModel({
    required this.text,
    required this.imageUrls,
    this.tags = const [],
  });

  // Firestore에 저장할 데이터를 Map 형태로 변환
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageUrls': imageUrls,
      'tags': tags,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Firestore에서 데이터를 불러와서 PostModel로 변환
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      text: map['text'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
