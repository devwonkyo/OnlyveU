
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/store_model.dart';

abstract class StoreState extends Equatable {
  const StoreState();
  
  @override
  List<Object> get props => [];
}

final class StoreInitial extends StoreState {}



class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
    final List<StoreModel> stores; // List 타입으로 수정

  const StoreLoaded(this.stores);

  @override
  List<Object> get props => [stores];
}


class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object> get props => [message];
}