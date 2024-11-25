import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/store_model.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object> get props => [];
}

class FetchPickupStore extends StoreEvent {
  const FetchPickupStore();

  @override
  List<Object> get props => [];
}

class SelectStore extends StoreEvent {
  final StoreModel selectedStore;
  const SelectStore(this.selectedStore);


  @override
  List<Object> get props => [selectedStore];
}
