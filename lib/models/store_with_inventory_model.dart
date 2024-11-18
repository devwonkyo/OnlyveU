import 'package:onlyveyou/models/inventory_model.dart';
import 'package:onlyveyou/models/store_model.dart';

class StoreWithInventoryModel {
  final String storeId;
  final String storeName;
  final String address;
  final String businessHours;
  final bool isActive;
  final String imageUrl;
  final int quantity;  // 재고 수량

  StoreWithInventoryModel({
    required this.storeId,
    required this.storeName,
    required this.address,
    required this.isActive,
    required this.businessHours,
    required this.imageUrl,
    required this.quantity,
  });

  factory StoreWithInventoryModel.fromStoreAndInventory({
    required StoreModel store,
    required InventoryModel inventory,
  }) {
    return StoreWithInventoryModel(
      storeId: store.storeId,
      storeName: store.storeName,
      isActive: store.isActive,
      address: store.address,
      businessHours: store.businessHours,
      imageUrl: store.imageUrl,
      quantity: inventory.quantity,
    );
  }
}