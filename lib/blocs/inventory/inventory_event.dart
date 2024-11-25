part of 'inventory_bloc.dart';

sealed class InventoryEvent extends Equatable {
  const InventoryEvent();
}

// 특정 상품의 매장 정보를 알아오는 이벤트
class GetStoreListWithProductIdEvent extends InventoryEvent {
  final String productId;

  GetStoreListWithProductIdEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}
