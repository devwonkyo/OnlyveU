class ReviewModel {
  /// 리뷰 ID
  final String reviewId;

  /// 상품 ID
  final String productId;

  /// 작성자 ID
  final String userId;

  final String userName;

  /// 평점
  final double rating;

  /// 리뷰 내용
  final String content;

  /// 리뷰 이미지 URL 리스트
  final List<String> imageUrls;

  /// 좋아요한 사용자 ID 목록 -> 이 리뷰가 도움이돼요
  final List<String> likedUserIds;

  /// 작성일
  final DateTime createdAt;

  ReviewModel({
    required this.reviewId,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.content,
    this.imageUrls = const [],
    this.likedUserIds = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'content': content,
      'imageUrls': imageUrls,
      'likedUserIds': likedUserIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map['reviewId'] as String,
      productId: map['productId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      rating: (map['rating'] as num).toDouble(),
      content: map['content'] as String,
      imageUrls: List<String>.from(map['imageUrls'] as List? ?? []),
      likedUserIds: List<String>.from(map['likedUserIds'] as List? ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  ReviewModel copyWith({
    String? reviewId,
    String? productId,
    String? userId,
    String? userName,
    double? rating,
    String? content,
    List<String>? imageUrls,
    List<String>? likedUserIds,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      likedUserIds: likedUserIds ?? this.likedUserIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}