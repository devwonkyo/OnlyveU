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
    
  final String productId;
  final String productName;
  final String productImageUrl;
  final int productPrice;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'],
      productName: map['productName'],
      productImageUrl: map['productImageUrl'],
      productPrice: map['productPrice'],
      quantity: map['quantity'],
    );
  }
}
