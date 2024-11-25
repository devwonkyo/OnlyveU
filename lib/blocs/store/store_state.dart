import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/store_model.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object> get props => [];
}

final class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}


//전체 매장 불러오기 
class StoreLoaded extends StoreState {
  final List<StoreModel> stores; // List 타입으로 수정

  const StoreLoaded(this.stores);

  @override
  List<Object> get props => [stores];
}

//매장 선택했을 때
class StoreSelected extends StoreState {
  final StoreModel selectedStore; // 선택된 매장을 저장

  const StoreSelected(this.selectedStore);

  @override
  List<Object> get props => [selectedStore];
}


class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object> get props => [message];
}
