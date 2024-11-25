import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/store_model.dart';
import 'package:onlyveyou/models/store_with_inventory_model.dart';
import 'package:onlyveyou/repositories/inventory/inventory_repository.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;

  InventoryBloc(this.repository) : super(InventoryInitial()) {
    on<GetStoreListWithProductIdEvent>(getStoreListWithProductId);
  }


  Future<void> getStoreListWithProductId(GetStoreListWithProductIdEvent event, Emitter<InventoryState> emit) async {
    emit(InventoryLoadStoreLoading());
    try {
      final storeWithInventory = await repository.getStoresWithInventory(event.productId);
      emit(InventoryLoadedStore(storeWithInventory));
    } catch (e) {
      emit(InventoryLoadStoreError("error : $e"));
    }
  }


}

