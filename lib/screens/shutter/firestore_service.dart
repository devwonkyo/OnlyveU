import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PostModel>> getPosts() {
    try {
      return _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return PostModel.fromMap(data);
        }).toList();
      });
    } catch (e) {
      print('Error in getPosts: $e');
      rethrow;
    }
  }
}
