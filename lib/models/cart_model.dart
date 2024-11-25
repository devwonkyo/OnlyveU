class CartModel {
  /// 상품 ID - products 컬렉션의 문서 ID와 매칭
  final String productId;
  final String productName;
  final String productImageUrl;
  final int productPrice;
  final int discountPercent; // 할인율 추가

  /// 해당 상품의 장바구니 수량
  final int quantity;

  CartModel({
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
    required this.discountPercent, // 필수 파라미터로 추가
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      'discountPercent': discountPercent, // toMap에 추가
      'quantity': quantity,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      productId: map['productId'],
      productName: map['productName'],
      productImageUrl: map['productImageUrl'],
      productPrice: map['productPrice'],
      discountPercent: map['discountPercent'] ?? 0, // fromMap에 추가, 기본값 0
      quantity: map['quantity'] ?? 1,
    );
  }
}

// 레퍼지토리에서 카트모델을 오더아이템 모델로 변경할때는
// price에 할일율이 적용된 가격을 넘겨주기
