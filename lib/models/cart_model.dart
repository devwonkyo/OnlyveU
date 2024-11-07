class CartModel {
  /// 상품 ID - products 컬렉션의 문서 ID와 매칭
  final String productId;

  /// 해당 상품의 장바구니 수량
  final int quantity;

  CartModel({
    required this.productId,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      productId: map['productId'],
      quantity: map['quantity'] ?? 1,
    );
  }
}
