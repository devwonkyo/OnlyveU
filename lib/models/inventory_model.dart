class InventoryModel {
  /// 제품ID
  final String productId;

  /// 전체 재고 수량
  final int stock;

  /// 매장별 재고 현황 Map
  /// key: 매장 ID
  /// value: 해당 매장의 재고 수량
  final Map<String, int> storeStock;
  //A -> 30
  //B -> 20
  //storeStock['A']

  InventoryModel({
    required this.productId,
    required this.stock,
    required this.storeStock,
  });

  /// InventoryModel 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'stock': stock,
      'storeStock': storeStock,
    };
  }

  /// Map에서 InventoryModel 객체를 생성
  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      productId: map['productId'] as String,
      stock: map['stock'] as int,
      storeStock: Map<String, int>.from(map['storeStock'] as Map),
    );
  }
}
