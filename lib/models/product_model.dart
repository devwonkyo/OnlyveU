class ProductModel {
  String productId; // 제품 고유 ID
  String name; // 제품 이름
  String brandName; // 브랜드 명
  List<String> productImageList; // 제품 이미지 URL 리스트
  List<String> descriptionImageList; // 제품 정보 이미지 URL 리스트
  String price; // 가격
  int discountPercent; // 할인율
  int stock; // 재고
  String categoryId; // 제품 카테고리 ID
  List<String> favoriteList; // 좋아요한 리스트
  List<String> reviewList; // 리뷰 리스트
  List<String> tagList; // 태그 리스트

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
  });

  // JSON 데이터를 ProductModel 객체로 변환
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'],
      name: json['name'],
      brandName: json['brandName'],
      productImageList: List<String>.from(json['productImageList']),
      descriptionImageList: List<String>.from(json['descriptionImageList']),
      price: json['price'],
      discountPercent: json['discountPercent'],
      stock: json['stock'],
      categoryId: json['categoryId'],
      favoriteList: List<String>.from(json['favoriteList']),
      reviewList: List<String>.from(json['reviewList']),
      tagList: List<String>.from(json['tagList']),
    );
  }

  // ProductModel 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
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
    };
  }
}