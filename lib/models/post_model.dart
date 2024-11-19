import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String text;
  final List<String> imageUrls;
  final List<String> tags;
  final DateTime createdAt;
  final String authorUid;
  final String authorName;
  final String authorProfileImageUrl; // 추가된 필드
  final int likes;
  final List<String> likedBy;

  PostModel({
    required this.id,
    required this.text,
    required this.imageUrls,
    required this.tags,
    DateTime? createdAt,
    required this.authorUid,
    required this.authorName,
    required this.authorProfileImageUrl, // 생성자에 추가
    this.likes = 0,
    this.likedBy = const [],
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imageUrls': imageUrls,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'authorUid': authorUid,
      'authorName': authorName,
      'authorProfileImageUrl': authorProfileImageUrl, // map에 추가
      'likes': likes,
      'likedBy': likedBy,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PostModel(
      id: documentId,
      text: map['text'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      authorUid: map['authorUid'] ?? '',
      authorName: map['authorName'] ?? 'Unknown',
      authorProfileImageUrl: map['authorProfileImageUrl'] ?? '', // map에서 추출
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }
}
