import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String text;
  final List<String> imageUrls;
  final List<String> tags;
  final DateTime createdAt;
  final String authorUid; // 작성자 UID

  PostModel({
    required this.text,
    required this.imageUrls,
    required this.tags,
    DateTime? createdAt,
    required this.authorUid,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageUrls': imageUrls,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'authorUid': authorUid,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    // Handle different types of createdAt field
    DateTime parseCreatedAt(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        return DateTime.now(); // Fallback to current time if format is unknown
      }
    }

    try {
      return PostModel(
        text: map['text']?.toString() ?? '',
        imageUrls: List<String>.from(map['imageUrls'] ?? []),
        tags: List<String>.from(map['tags'] ?? []),
        createdAt: parseCreatedAt(map['createdAt']),
        authorUid: map['authorUid'] ?? '',
      );
    } catch (e) {
      print('Error parsing PostModel: $e');
      // Return a default PostModel if parsing fails
      return PostModel(
        text: map['text']?.toString() ?? '',
        imageUrls: List<String>.from(map['imageUrls'] ?? []),
        tags: List<String>.from(map['tags'] ?? []),
        createdAt: DateTime.now(),
        authorUid: map['authorUid'] ?? '',
      );
    }
  }
}
