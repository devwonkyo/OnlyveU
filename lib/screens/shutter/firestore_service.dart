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
          .asyncMap((snapshot) async {
        List<PostModel> posts = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          // 사용자 정보 가져오기
          final userDoc =
              await _firestore.collection('users').doc(data['authorUid']).get();

          // PostModel 생성 시 프로필 이미지 URL 포함
          final postData = {
            ...data,
            'authorProfileImageUrl':
                (userDoc.data() as Map<String, dynamic>)?['profileImageUrl'] ??
                    '',
          };

          posts.add(PostModel.fromMap(postData, doc.id));
        }
        return posts;
      });
    } catch (e) {
      print('Error in getPosts: $e');
      rethrow;
    }
  }

  Future<String> fetchNickname(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc['nickname'] ?? 'Unknown User';
      }
    } catch (e) {
      print('Error fetching nickname: $e');
    }
    return 'Unknown User';
  }

  // 좋아요 토글 기능
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      return _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('Post does not exist!');
        }
        List<String> likedBy =
            List<String>.from(postDoc.data()?['likedBy'] ?? []);
        int currentLikes = postDoc.data()?['likes'] ?? 0;

        if (likedBy.contains(userId)) {
          // 좋아요 취소
          likedBy.remove(userId);
          currentLikes -= 1;
        } else {
          // 좋아요 추가
          likedBy.add(userId);
          currentLikes += 1;
        }

        transaction.update(postRef, {
          'likedBy': likedBy,
          'likes': currentLikes,
        });
      });
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // 특정 게시물의 좋아요 상태 스트림
  Stream<PostModel> getPostLikeStatus(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) {
        throw Exception('Post does not exist!');
      }

      final data = doc.data()!;
      // 사용자 정보 가져오기
      final userDoc =
          await _firestore.collection('users').doc(data['authorUid']).get();

      // PostModel 생성 시 프로필 이미지 URL 포함
      final postData = {
        ...data,
        'authorProfileImageUrl':
            (userDoc.data() as Map<String, dynamic>)?['profileImageUrl'] ?? '',
      };

      return PostModel.fromMap(postData, doc.id);
    });
  }
}
