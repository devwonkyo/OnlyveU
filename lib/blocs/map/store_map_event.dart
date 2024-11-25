part of 'store_map_bloc.dart';



// store_map_event.dart
abstract class StoreMapEvent extends Equatable{}

class LoadStoreLocation extends StoreMapEvent {
  final String address;
  LoadStoreLocation(this.address);

  @override
  // TODO: implement props
  List<Object?> get props => [address];
}

class UpdateMarker extends StoreMapEvent {
  final NLatLng position;
  UpdateMarker(this.position);

  @override
  // TODO: implement props
  List<Object?> get props => [position];
}
