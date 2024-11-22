part of 'store_map_bloc.dart';

// store_map_state.dart
abstract class StoreMapState extends Equatable{}

class StoreMapInitial extends StoreMapState {
  @override
  List<Object?> get props => [];
}

class StoreMapLoading extends StoreMapState {
  @override
  List<Object?> get props => [];
}

class StoreMapLoaded extends StoreMapState {
  final NLatLng position;
  StoreMapLoaded(this.position);

  @override
  List<Object?> get props => [position];
}

class StoreMapError extends StoreMapState {
  final String message;
  StoreMapError(this.message);

  @override
  List<Object?> get props => [message];
}