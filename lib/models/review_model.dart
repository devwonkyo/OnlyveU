import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/order_model.dart';

class ReviewModel {
  /// 리뷰 ID
  final String? reviewId;

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

  /// 구매 날짜
  final DateTime purchaseDate;

  /// 주문 유형 (delivery가 기본값)
  final OrderType orderType;

  /// 상품 이미지 URL
  final String productImage;

  /// 상품 이름
  final String productName;

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
    required this.purchaseDate,
    this.orderType = OrderType.delivery, // 기본값 설정
    required this.productImage, // 새로 추가된 필드
    required this.productName, // 새로 추가된 필드
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
      'createdAt': Timestamp.fromDate(createdAt),  // 수정된 부분
      'purchaseDate': Timestamp.fromDate(purchaseDate), // 수정된 부분
      'orderType': orderType.toString().split('.').last,
      'productImage': productImage,
      'productName': productName,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map['reviewId'] as String?,
      productId: map['productId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      rating: (map['rating'] as num).toDouble(),
      content: map['content'] as String,
      imageUrls: List<String>.from(map['imageUrls'] as List? ?? []),
      likedUserIds: List<String>.from(map['likedUserIds'] as List? ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      purchaseDate: (map['purchaseDate'] as Timestamp).toDate(),
      orderType: map['orderType'] == 'pickup'
          ? OrderType.pickup
          : OrderType.delivery,
      productImage: map['productImage'] as String,
      productName: map['productName'] as String,
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
    DateTime? purchaseDate,
    OrderType? orderType,
    String? productImage, // 새로 추가된 필드
    String? productName, // 새로 추가된 필드
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
      purchaseDate: purchaseDate ?? this.purchaseDate,
      orderType: orderType ?? this.orderType,
      productImage: productImage ?? this.productImage, // 새로 추가된 필드
      productName: productName ?? this.productName, // 새로 추가된 필드
    );
  }
}