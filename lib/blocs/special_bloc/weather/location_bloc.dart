import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../repositories/special/weather/location_repository.dart';

abstract class LocationEvent {}

class GetCurrentLocation extends LocationEvent {}

class StartLocationUpdates extends LocationEvent {}

class StopLocationUpdates extends LocationEvent {}

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

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _repository;
  StreamSubscription<LocationData>? _locationSubscription;

  LocationBloc({required LocationRepository repository})
      : _repository = repository,
        super(LocationInitial()) {
    on<GetCurrentLocation>((event, emit) async {
      try {
        emit(LocationLoading());
        final locationData = await _repository.getCurrentLocationData();
        if (!isClosed) {
          emit(LocationSuccess(
            position: locationData.position,
            marker: locationData.marker,
            cameraPosition: locationData.cameraPosition,
          ));
        }
      } catch (e) {
        if (!isClosed) {
          emit(LocationError(e.toString()));
        }
      }
    });

    on<StartLocationUpdates>((event, emit) async {
      await _locationSubscription?.cancel();

      emit(LocationLoading());

      await emit.forEach<LocationData>(
        _repository.getLocationDataStream(),
        onData: (locationData) => LocationSuccess(
          position: locationData.position,
          marker: locationData.marker,
          cameraPosition: locationData.cameraPosition,
        ),
        onError: (error, stackTrace) => LocationError(error.toString()),
      );
    });

    on<StopLocationUpdates>((event, emit) async {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
    });
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    return super.close();
  }
}
