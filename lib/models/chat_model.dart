import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String profileImageUrl;
  final String msg;
  final Timestamp timestamp;

  ChatModel({
    required this.profileImageUrl,
    required this.msg,
    required this.timestamp,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ChatModel(
      profileImageUrl: data['profileImageUrl'] ?? '',
      msg: data['msg'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileImageUrl': profileImageUrl,
      'msg': msg,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'ChatModel(profileImageUrl: $profileImageUrl, msg: $msg, timestamp: $timestamp)';
  }
}
