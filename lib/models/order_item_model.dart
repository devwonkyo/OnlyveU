// class OrderItemModel {
//   /// 상품 ID
//   final String productId;

//   /// 주문 수량
//   final int quantity;

//   OrderItemModel({
//     required this.productId,
//     required this.quantity,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'productId': productId,
//       'quantity': quantity,
//     };
//   }

//   factory OrderItemModel.fromMap(Map<String, dynamic> map) {
//     return OrderItemModel(
//       productId: map['productId'],
//       quantity: map['quantity'],
//     );
//   }
// }
class OrderItemModel {
  final String? orderItemId;  // 주문 아이템 ID 추가
  final String productId;
  final String productName;
  final String productImageUrl;
  final int productPrice;
  final int quantity;
  final String? reviewId;

  OrderItemModel({
    this.orderItemId,  // optional parameter
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
    required this.quantity,
    this.reviewId,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderItemId': orderItemId,  // 주문 아이템 ID 추가
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      'quantity': quantity,
      'reviewId': reviewId,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      orderItemId: map['orderItemId'],  // 주문 아이템 ID 추가
      productId: map['productId'],
      productName: map['productName'],
      productImageUrl: map['productImageUrl'],
      productPrice: map['productPrice'],
      quantity: map['quantity'],
      reviewId: map['reviewId'],
    );
  }

  OrderItemModel copyWith({
    String? orderItemId,  // 주문 아이템 ID 추가
    String? productId,
    String? productName,
    String? productImageUrl,
    int? productPrice,
    int? quantity,
    String? reviewId,
  }) {
    return OrderItemModel(
      orderItemId: orderItemId ?? this.orderItemId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      productPrice: productPrice ?? this.productPrice,
      quantity: quantity ?? this.quantity,
      reviewId: reviewId ?? this.reviewId,
    );
  }
}