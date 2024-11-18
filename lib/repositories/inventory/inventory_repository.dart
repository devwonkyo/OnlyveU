import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/inventory_model.dart';
import 'package:onlyveyou/models/store_model.dart';
import 'package:onlyveyou/models/store_with_inventory_model.dart';

class InventoryRepository {
  final FirebaseFirestore _firestore;

  InventoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<StoreWithInventoryModel>> getStoresWithInventory(String productId) async {
    try {
      // 1. inventories 컬렉션에서 productId가 일치하는 문서들 조회
      final QuerySnapshot inventorySnapshot = await _firestore
          .collection('inventories')
          .where('productId', isEqualTo: productId)
          .get();

      if (inventorySnapshot.docs.isEmpty) {
        return [];
      }

      // 2. inventory 데이터를 Map으로 변환 (storeId를 키로 사용)
      final Map<String, InventoryModel> inventoryMap = {
        for (var doc in inventorySnapshot.docs)
          (doc.data() as Map<String, dynamic>)['storeId']:
          InventoryModel.fromMap(doc.data() as Map<String, dynamic>)
      };

      // 3. stores 컬렉션에서 storeId들에 해당하는 매장 정보 조회
      List<StoreWithInventoryModel> storesWithInventory = [];
      final storeIds = inventoryMap.keys.toList();

      for (var i = 0; i < storeIds.length; i += 10) {
        final end = (i + 10 < storeIds.length) ? i + 10 : storeIds.length;
        final chunk = storeIds.sublist(i, end);

        final QuerySnapshot storeSnapshot = await _firestore
            .collection('stores')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        // 매장 정보와 재고 정보를 결합
        final stores = storeSnapshot.docs.map((doc) {
          final storeId = doc.id;
          final store = StoreModel.fromMap({
            ...doc.data() as Map<String, dynamic>,
            'id': storeId,
          });
          final inventory = inventoryMap[storeId]!;

          return StoreWithInventoryModel.fromStoreAndInventory(
            store: store,
            inventory: inventory,
          );
        }).toList();

        storesWithInventory.addAll(stores);
      }

      // 재고 수량으로 정렬 (선택사항)
      // storesWithInventory.sort((a, b) => b.quantity.compareTo(a.quantity));

      return storesWithInventory;
    } catch (e) {
      throw Exception('Failed to fetch stores with inventory: $e');
    }
  }
}