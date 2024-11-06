class OrderItemModel {
  /// 상품 ID
  final String productId;

  /// 주문 수량
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'],
      quantity: map['quantity'],
    );
  }
}
