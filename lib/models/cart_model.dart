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

/////
//유저의 카드모델에 있는걸 뿌려주면 되는거 아냐?
//카트모델로 끌어온다.
//좋아요 넣었
//

//좋아요 버튼을 누르면 유저모델에 데이터 추가하는 로직을 지워야한다.
