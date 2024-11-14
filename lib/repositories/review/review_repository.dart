import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/review_model.dart';

class ReviewRepository{
  final FirebaseFirestore _firestore;

  ReviewRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ReviewModel>> findProductReview(String productId) async {
    try {
      // reviews 컬렉션에서 productId가 일치하는 문서들을 가져옴
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          // .orderBy('createdAt', descending: true) // 최신순 정렬
          .get();

      // 문서들을 ReviewModel 리스트로 변환
      final reviews = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ReviewModel(
          reviewId: doc.id,
          productId: data['productId'],
          userId: data['userId'],
          userName: data['userName'],
          rating: (data['rating'] as num).toDouble(),
          content: data['content'],
          imageUrls: List<String>.from(data['imageUrls'] ?? []),
          likedUserIds: List<String>.from(data['likedUserIds'] ?? []),
          createdAt: DateTime.parse(data['createdAt']),
        );
      }).toList();

      return reviews;
    } catch (e) {
      print('리뷰 데이터 가져오기 실패: $e');
      return []; // 에러 발생 시 빈 리스트 반환
    }
  }

  Future<void> addLikeReview(String reviewId, String userId) async {
    try {
      // 파이어베이스에서 해당 reviewId의 문서 가져오기
      final reviewRef = FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId);

      // 현재 문서의 likedUserIds 확인
      final doc = await reviewRef.get();
      List<String> likedUserIds = List<String>.from(doc.data()?['likedUserIds'] ?? []);

      // userId가 있으면 제거, 없으면 추가
      if (likedUserIds.contains(userId)) {
        await reviewRef.update({
          'likedUserIds': FieldValue.arrayRemove([userId])
        });
      } else {
        await reviewRef.update({
          'likedUserIds': FieldValue.arrayUnion([userId])
        });
      }
    } catch(e) {
      print('리뷰 데이터 가져오기 실패: $e');
    }
  }

  Future<void> addReview(ReviewModel reviewModel) async {
    try {
      // 1. 사용자 이름 가져오기
      final userDoc = await _firestore
          .collection('users')
          .doc(reviewModel.userId)
          .get();
      final userName = userDoc.data()?['nickname'] as String;

      // 2. 리뷰 문서 생성하고 ID 받기
      final reviewRef = _firestore.collection('reviews').doc();
      final reviewId = reviewRef.id;

      // 3. 최종 리뷰 모델 생성
      final finalReview = reviewModel.copyWith(
        reviewId: reviewId,
        userName: userName,
      );

      // 4. 리뷰 저장
      await reviewRef.set(finalReview.toMap());
    } catch (e) {
      throw Exception('리뷰 생성 실패: $e');
    }
  }



}