import 'package:cloud_firestore/cloud_firestore.dart';

class VoteModel {
  final String userId;
  final String productId;
  final Timestamp timestamp;

  VoteModel({
    required this.userId,
    required this.productId,
    required this.timestamp,
  });

  factory VoteModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return VoteModel(
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'VoteModel(userId: $userId, productId: $productId, timestamp: $timestamp)';
  }
}
