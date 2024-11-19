import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../repositories/special/weather/location_repository.dart';

// Events
abstract class LocationEvent {}

class GetCurrentLocation extends LocationEvent {}

class StartLocationUpdates extends LocationEvent {}

class StopLocationUpdates extends LocationEvent {}

// States
abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationSuccess extends LocationState {
  final Position position;
  final Marker marker;
  final CameraPosition cameraPosition;

  LocationSuccess({
    required this.position,
    required this.marker,
    required this.cameraPosition,
  });
}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}

// Bloc
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _repository;
  StreamSubscription<Position>? _locationSubscription;

  LocationBloc({required LocationRepository repository})
      : _repository = repository,
        super(LocationInitial()) {
    on<GetCurrentLocation>((event, emit) async {
      try {
        emit(LocationLoading());

        final position = await _repository.getCurrentLocation();
        final latLng = _repository.positionToLatLng(position);

        emit(LocationSuccess(
          position: position,
          marker: _repository.createLocationMarker(latLng),
          cameraPosition: _repository.updateCameraPosition(latLng),
        ));
      } catch (e) {
        emit(LocationError(e.toString()));
      }
    });

    on<StartLocationUpdates>((event, emit) async {
      _locationSubscription?.cancel();
      _locationSubscription = _repository.getLocationStream().listen(
        (position) {
          final latLng = _repository.positionToLatLng(position);

          emit(LocationSuccess(
            position: position,
            marker: _repository.createLocationMarker(latLng),
            cameraPosition: _repository.updateCameraPosition(latLng),
          ));
        },
        onError: (error) => emit(LocationError(error.toString())),
      );
    });

    on<StopLocationUpdates>((event, emit) {
      _locationSubscription?.cancel();
      _locationSubscription = null;
    });
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
