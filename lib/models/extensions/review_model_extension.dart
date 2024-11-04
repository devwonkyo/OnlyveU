import 'package:onlyveyou/models/review_model.dart';

extension ReviewModelExtension on ReviewModel {
  /// 좋아요 수 계산
  int get likeCount => likedUserIds.length;

  /// 특정 사용자의 좋아요 여부 확인
  bool isLikedBy(String userId) => likedUserIds.contains(userId);
}