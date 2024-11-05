import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/cart_model.dart';

class ProductModel {
  final String productId;
  final String name;
  final String brandName;
  final List<String> productImageList;
  final List<String> descriptionImageList;
  final String price;
  final int discountPercent;
  final String categoryId;
  final String subcategoryId;
  final List<String> favoriteList;
  final List<String> reviewList;
  final List<String> tagList;
  final List<CartModel> cartList;
  final int visitCount;
  final double rating;
  final DateTime registrationDate;
  final int salesVolume;
  final bool isBest;
  final bool isPopular;

  ProductModel({
    required this.productId,
    required this.name,
    required this.brandName,
    required this.productImageList,
    required this.descriptionImageList,
    required this.price,
    required this.discountPercent,
    required this.categoryId,
    required this.subcategoryId,
    required this.favoriteList,
    required this.reviewList,
    required this.tagList,
    required this.cartList,
    required this.visitCount,
    required this.rating,
    required this.registrationDate,
    required this.salesVolume,
    this.isBest = false,
    this.isPopular = false,
  });

  // 일반 Map으로부터 ProductModel 생성
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    //TODO MAP 타입변환
    // Timestamp를 DateTime으로 변환
    Timestamp timestamp = map['registrationDate'] as Timestamp;
    DateTime date = timestamp.toDate();

    return ProductModel(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      brandName: map['brandName'] ?? '',
      productImageList: List<String>.from(map['productImageList'] ?? []),
      descriptionImageList:
          List<String>.from(map['descriptionImageList'] ?? []),
      price: map['price'] ?? '0',
      discountPercent: map['discountPercent'] ?? 0,
      categoryId: map['categoryId'] ?? '',
      subcategoryId: map['subcategoryId'] ?? '',
      favoriteList: List<String>.from(map['favoriteList'] ?? []),
      reviewList: List<String>.from(map['reviewList'] ?? []),
      tagList: List<String>.from(map['tagList'] ?? []),
      cartList: (map['cartList'] as List<dynamic>? ?? [])
          .map((item) => CartModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      visitCount: map['visitCount'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      registrationDate: date,
      salesVolume: map['salesVolume'] ?? 0,
      isBest: map['isBest'] ?? false,
      isPopular: map['isPopular'] ?? false,
    );
  }

  // Firestore에 저장하기 위한 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'brandName': brandName,
      'productImageList': productImageList,
      'descriptionImageList': descriptionImageList,
      'price': price,
      'discountPercent': discountPercent,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'favoriteList': favoriteList,
      'reviewList': reviewList,
      'tagList': tagList,
      'cartList': cartList.map((item) => item.toMap()).toList(),
      'visitCount': visitCount,
      'rating': rating,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'salesVolume': salesVolume,
      'isBest': isBest,
      'isPopular': isPopular,
    };
  }

  ProductModel copyWith({
    String? productId,
    String? name,
    String? brandName,
    List<String>? productImageList,
    List<String>? descriptionImageList,
    String? price,
    int? discountPercent,
    String? categoryId,
    String? subcategoryId,
    List<String>? favoriteList,
    List<String>? reviewList,
    List<String>? tagList,
    List<CartModel>? cartList,
    int? visitCount,
    double? rating,
    DateTime? registrationDate,
    int? salesVolume,
    bool? isBest,
    bool? isPopular,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      brandName: brandName ?? this.brandName,
      productImageList: productImageList ?? this.productImageList,
      descriptionImageList: descriptionImageList ?? this.descriptionImageList,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      favoriteList: favoriteList ?? this.favoriteList,
      reviewList: reviewList ?? this.reviewList,
      tagList: tagList ?? this.tagList,
      cartList: cartList ?? this.cartList,
      visitCount: visitCount ?? this.visitCount,
      rating: rating ?? this.rating,
      registrationDate: registrationDate ?? this.registrationDate,
      salesVolume: salesVolume ?? this.salesVolume,
      isBest: isBest ?? this.isBest,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}
/////////////////////////////
// import 'package:onlyveyou/models/cart_model.dart';
//
// class ProductModel {
//   // 제품 고유 ID
//   String productId;
//
//   // 제품 이름
//   String name;
//
//   // 브랜드 명
//   String brandName;
//
//   // 제품 이미지 URL 리스트
//   List<String> productImageList;
//
//   // 제품 정보 이미지 URL 리스트
//   List<String> descriptionImageList;
//
//   // 가격
//   String price;
//
//   // 할인율
//   int discountPercent;
//
//   // 상위 카테고리 ID (예: 1)
//   String categoryId;
//
//   // 소분류 카테고리 ID (예: 1_1 또는 1_2)
//   String subcategoryId;
//
//   // 좋아요를 한 유저 ID 리스트
//   List<String> favoriteList;
//
//   // 제품에 대한 리뷰 ID 리스트
//   List<String> reviewList;
//
//   // 제품에 대한 태그 ID 리스트
//   List<String> tagList;
//
//   // 장바구니에 담긴 항목 리스트
//   List<CartModel> cartList;
//
//   // 방문자 수
//   int visitCount;
//
//   // 제품 평점
//   double rating;
//
//   // 제품 등록일
//   DateTime registrationDate;
//
//   // 판매량
//   int salesVolume;
//
//   // BEST 상품 여부
//   bool isBest;
//
//   // 인기 상품 여부
//   bool isPopular;
//
//   ProductModel({
//     required this.productId,
//     required this.name,
//     required this.brandName,
//     required this.productImageList,
//     required this.descriptionImageList,
//     required this.price,
//     required this.discountPercent,
//     required this.categoryId,
//     required this.subcategoryId,
//     required this.favoriteList,
//     required this.reviewList,
//     required this.tagList,
//     required this.cartList,
//     required this.visitCount,
//     required this.rating,
//     required this.registrationDate,
//     required this.salesVolume,
//     required this.isBest,
//     required this.isPopular,
//   });
//
//   // Map을 ProductModel 인스턴스로 변환
//   factory ProductModel.fromMap(Map<String, dynamic> map) {
//     return ProductModel(
//       productId: map['productId'] ?? '',
//       name: map['name'] ?? '',
//       brandName: map['brandName'] ?? '',
//       productImageList: List<String>.from(map['productImageList'] ?? []),
//       descriptionImageList: List<String>.from(map['descriptionImageList'] ?? []),
//       price: map['price'] ?? '0',
//       discountPercent: map['discountPercent'] ?? 0,
//       categoryId: map['categoryId'] ?? '',
//       subcategoryId: map['subcategoryId'] ?? '',
//       favoriteList: List<String>.from(map['favoriteList'] ?? []),
//       reviewList: List<String>.from(map['reviewList'] ?? []),
//       tagList: List<String>.from(map['tagList'] ?? []),
//       cartList: List<CartModel>.from(
//           (map['cartList'] ?? []).map((item) => CartModel.fromMap(item))
//       ),
//       visitCount: map['visitCount'] ?? 0,
//       rating: (map['rating'] ?? 0.0).toDouble(),
//       registrationDate: map['registrationDate'] != null
//           ? DateTime.parse(map['registrationDate'])
//           : DateTime.now(),
//       salesVolume: map['salesVolume'] ?? 0,
//       isBest: map['isBest'] ?? false,
//       isPopular: map['isPopular'] ?? false,
//     );
//   }
//
//   // ProductModel 인스턴스를 Map으로 변환
//   Map<String, dynamic> toMap() {
//     return {
//       'productId': productId,
//       'name': name,
//       'brandName': brandName,
//       'productImageList': productImageList,
//       'descriptionImageList': descriptionImageList,
//       'price': price,
//       'discountPercent': discountPercent,
//       'categoryId': categoryId,
//       'subcategoryId': subcategoryId,
//       'favoriteList': favoriteList,
//       'reviewList': reviewList,
//       'tagList': tagList,
//       'cartList': cartList.map((cartItem) => cartItem.toMap()).toList(),
//       'visitCount': visitCount,
//       'rating': rating,
//       'registrationDate': registrationDate.toIso8601String(),
//       'salesVolume': salesVolume,
//       'isBest': isBest,
//       'isPopular': isPopular,
//     };
//   }
//
//   // 기존 인스턴스를 바탕으로 일부 필드만 변경한 새 인스턴스 생성
//   ProductModel copyWith({
//     String? productId,
//     String? name,
//     String? brandName,
//     List<String>? productImageList,
//     List<String>? descriptionImageList,
//     String? price,
//     int? discountPercent,
//     String? categoryId,
//     String? subcategoryId,
//     List<String>? favoriteList,
//     List<String>? reviewList,
//     List<String>? tagList,
//     List<CartModel>? cartList,
//     int? visitCount,
//     double? rating,
//     DateTime? registrationDate,
//     int? salesVolume,
//     bool? isBest,
//     bool? isPopular,
//   }) {
//     return ProductModel(
//       productId: productId ?? this.productId,
//       name: name ?? this.name,
//       brandName: brandName ?? this.brandName,
//       productImageList: productImageList ?? this.productImageList,
//       descriptionImageList: descriptionImageList ?? this.descriptionImageList,
//       price: price ?? this.price,
//       discountPercent: discountPercent ?? this.discountPercent,
//       categoryId: categoryId ?? this.categoryId,
//       subcategoryId: subcategoryId ?? this.subcategoryId,
//       favoriteList: favoriteList ?? this.favoriteList,
//       reviewList: reviewList ?? this.reviewList,
//       tagList: tagList ?? this.tagList,
//       cartList: cartList ?? this.cartList,
//       visitCount: visitCount ?? this.visitCount,
//       rating: rating ?? this.rating,
//       registrationDate: registrationDate ?? this.registrationDate,
//       salesVolume: salesVolume ?? this.salesVolume,
//       isBest: isBest ?? this.isBest,
//       isPopular: isPopular ?? this.isPopular,
//     );
//   }
// }
