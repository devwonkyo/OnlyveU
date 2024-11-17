part of 'inventory_bloc.dart';

sealed class InventoryState extends Equatable {
  const InventoryState();
}

final class InventoryInitial extends InventoryState {
  @override
  List<Object> get props => [];
}

// 로딩 상태
class InventoryLoadStoreLoading extends InventoryState {
  @override
  List<Object> get props => [];
}

// 에러 상태
class InventoryLoadStoreError extends InventoryState {
  final String message;

  InventoryLoadStoreError(this.message);

  @override
  List<Object?> get props => [message];
}

// 매장목록이 로드된 상태
class InventoryLoadedStore extends InventoryState {
  final List<StoreWithInventoryModel> storeList;

  const InventoryLoadedStore(this.storeList);

  @override
  List<Object?> get props => [storeList];
}
