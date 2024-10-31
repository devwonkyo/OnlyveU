import 'package:cloud_firestore/cloud_firestore.dart';

// class ProductModel {
//   String productId; // 제품 고유 ID
//   String name; // 제품 이름
//   String brandName; // 브랜드 명
//   List<String> productImageList; // 제품 이미지 URL 리스트
//   List<String> descriptionImageList; // 제품 정보 이미지 URL 리스트
//   String price; // 가격
//   int discountPercent; // 할인율
//   int stock; // 재고
//   String categoryId; // 제품 카테고리 ID
//   List<String> favoriteList; // 좋아요한 리스트
//   List<String> reviewList; // 리뷰 리스트
//   List<String> tagList; // 태그 리스트
//
//   ProductModel({
//     required this.productId,
//     required this.name,
//     required this.brandName,
//     required this.productImageList,
//     required this.descriptionImageList,
//     required this.price,
//     required this.discountPercent,
//     required this.stock,
//     required this.categoryId,
//     required this.favoriteList,
//     required this.reviewList,
//     required this.tagList,
//   });
//
//   // JSON 데이터를 ProductModel 객체로 변환
//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     return ProductModel(
//       productId: json['productId'],
//       name: json['name'],
//       brandName: json['brandName'],
//       productImageList: List<String>.from(json['productImageList']),
//       descriptionImageList: List<String>.from(json['descriptionImageList']),
//       price: json['price'],
//       discountPercent: json['discountPercent'],
//       stock: json['stock'],
//       categoryId: json['categoryId'],
//       favoriteList: List<String>.from(json['favoriteList']),
//       reviewList: List<String>.from(json['reviewList']),
//       tagList: List<String>.from(json['tagList']),
//     );
//   }
//
//   // ProductModel 객체를 JSON으로 변환
//   Map<String, dynamic> toJson() {
//     return {
//       'productId': productId,
//       'name': name,
//       'brandName': brandName,
//       'productImageList': productImageList,
//       'descriptionImageList': descriptionImageList,
//       'price': price,
//       'discountPercent': discountPercent,
//       'stock': stock,
//       'categoryId': categoryId,
//       'favoriteList': favoriteList,
//       'reviewList': reviewList,
//       'tagList': tagList,
//     };
//   }
// }

// 데이터 넣을 공간
// product 모델2 로 해서 시험해봐도 된다.
class ProductModel {
  final String productId;
  final String name;
  final String brandName;
  final List<String> productImageList;
  final List<String> descriptionImageList;
  final String price;
  final int discountPercent;
  final int stock;
  final String categoryId;
  final List<String> favoriteList;
  final List<String> reviewList;
  final List<String> tagList;
  final bool isBest;
  final double rating;

  ProductModel({
    required this.productId,
    required this.name,
    required this.brandName,
    required this.productImageList,
    required this.descriptionImageList,
    required this.price,
    required this.discountPercent,
    required this.stock,
    required this.categoryId,
    required this.favoriteList,
    required this.reviewList,
    required this.tagList,
    this.isBest = false, // 기본값 설정
    this.rating = 0.0, // 기본값 설정
  });
  // 할인된 가격 계산 getter

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      productId: doc.id,
      name: data['name'] ?? '',
      brandName: data['brandName'] ?? '',
      productImageList: List<String>.from(data['productImageList'] ?? []),
      descriptionImageList:
          List<String>.from(data['descriptionImageList'] ?? []),
      price: data['price'] ?? '0',
      discountPercent: data['discountPercent'] ?? 0,
      stock: data['stock'] ?? 0,
      categoryId: data['categoryId'] ?? '',
      favoriteList: List<String>.from(data['favoriteList'] ?? []),
      reviewList: List<String>.from(data['reviewList'] ?? []),
      tagList: List<String>.from(data['tagList'] ?? []),
      isBest: data['isBest'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      brandName: json['brandName'] ?? '',
      productImageList: List<String>.from(json['productImageList'] ?? []),
      descriptionImageList:
          List<String>.from(json['descriptionImageList'] ?? []),
      price: json['price'] ?? '0',
      discountPercent: json['discountPercent'] ?? 0,
      stock: json['stock'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      favoriteList: List<String>.from(json['favoriteList'] ?? []),
      reviewList: List<String>.from(json['reviewList'] ?? []),
      tagList: List<String>.from(json['tagList'] ?? []),
      isBest: json['isBest'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brandName': brandName,
      'productImageList': productImageList,
      'descriptionImageList': descriptionImageList,
      'price': price,
      'discountPercent': discountPercent,
      'stock': stock,
      'categoryId': categoryId,
      'favoriteList': favoriteList,
      'reviewList': reviewList,
      'tagList': tagList,
      'isBest': isBest,
      'rating': rating,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      ...toMap(),
    };
  }

  bool isFavorite(String userId) {
    return favoriteList.contains(userId);
  }

  int get reviewCount => reviewList.length;

  int get discountedPrice {
    try {
      int originalPrice = int.parse(price);
      return (originalPrice * (100 - discountPercent) / 100).round();
    } catch (e) {
      return 0;
    }
  }

  ProductModel copyWith({
    String? productId,
    String? name,
    String? brandName,
    List<String>? productImageList,
    List<String>? descriptionImageList,
    String? price,
    int? discountPercent,
    int? stock,
    String? categoryId,
    List<String>? favoriteList,
    List<String>? reviewList,
    List<String>? tagList,
    bool? isBest,
    double? rating,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      brandName: brandName ?? this.brandName,
      productImageList: productImageList ?? this.productImageList,
      descriptionImageList: descriptionImageList ?? this.descriptionImageList,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      favoriteList: favoriteList ?? this.favoriteList,
      reviewList: reviewList ?? this.reviewList,
      tagList: tagList ?? this.tagList,
      isBest: isBest ?? this.isBest,
      rating: rating ?? this.rating,
    );
  }
}
