// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<PostModel>> fetchPosts() async {
    try {
      final snapshot = await _db.collection('posts').get();
      return snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }
}
