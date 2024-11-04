import 'package:onlyveyou/models/inventory_model.dart';

extension InventoryModelExtension on InventoryModel {
  /// 특정 매장의 재고 확인
  ///
  /// [storeId]: 확인하고자 하는 매장의 ID
  int getStoreStock(String storeId) {
    return storeStock[storeId] ?? 0;
  }

  /// 모든 매장의 총 재고 계산
  int getTotalStock() {
    return storeStock.values.fold(0, (sum, quantity) => sum + quantity);
  }
}