class CartModel {
  /// 상품 ID - products 컬렉션의 문서 ID와 매칭
  final String productId;
  final String productName;
  final String productImageUrl;
  final int productPrice;

  /// 해당 상품의 장바구니 수량
  final int quantity;

  CartModel({
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
    this.quantity = 1,
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

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      productId: map['productId'],
      productName: map['productName'],
      productImageUrl: map['productImageUrl'],
      productPrice: map['productPrice'],
      quantity: map['quantity'] ?? 1,
    );
  }
}
