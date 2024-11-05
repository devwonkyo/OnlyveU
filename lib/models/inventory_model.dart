class InventoryModel {
  final String productId;
  final String storeId;
  int quantity;

  InventoryModel({
    required this.productId,
    required this.storeId,
    required this.quantity,
  });

  // Create inventory from map (JSON)
  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      productId: map['productId'] as String,
      storeId: map['storeId'] as String,
      quantity: map['quantity'] as int,
    );
  }

  // Convert inventory to map (JSON)
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'storeId': storeId,
      'quantity': quantity,
    };
  }

  // Copy with method for creating a new instance with some modified fields
  InventoryModel copyWith({
    String? productId,
    String? storeId,
    int? quantity,
  }) {
    return InventoryModel(
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
      quantity: quantity ?? this.quantity,
    );
  }
}