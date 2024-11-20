import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../repositories/special/weather/location_repository.dart';

// Public Events
abstract class LocationEvent {}

class GetCurrentLocation extends LocationEvent {}

class StartLocationUpdates extends LocationEvent {}

class StopLocationUpdates extends LocationEvent {}

// Internal Events
class _LocationDataReceived extends LocationEvent {
  final LocationData locationData;
  _LocationDataReceived(this.locationData);
}

class _LocationError extends LocationEvent {
  final String error;
  _LocationError(this.error);
}

// States
abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationSuccess extends LocationState {
  final Position position;
  final Marker marker;
  final CameraPosition cameraPosition;
  final String address;

  LocationSuccess({
    required this.position,
    required this.marker,
    required this.cameraPosition,
    required this.address,
  });

  LocationSuccess copyWith({
    Position? position,
    Marker? marker,
    CameraPosition? cameraPosition,
    String? address,
  }) {
    return LocationSuccess(
      position: position ?? this.position,
      marker: marker ?? this.marker,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      address: address ?? this.address,
    );
  }
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
            address: locationData.address,
          ));
        }
      } catch (e) {
        if (!isClosed) {
          emit(LocationError('위치 정보를 가져오는데 실패했습니다: ${e.toString()}'));
        }
      }
    });

    on<StartLocationUpdates>((event, emit) async {
      await _locationSubscription?.cancel();
      emit(LocationLoading());

      try {
        if (!await _repository.checkLocationService()) {
          emit(LocationError("위치 서비스를 활성화해주세요"));
          return;
        }

        _locationSubscription = _repository.getLocationDataStream().listen(
          (locationData) {
            if (!isClosed) {
              add(_LocationDataReceived(locationData));
            }
          },
          onError: (error) {
            if (!isClosed) {
              add(_LocationError(error.toString()));
            }
          },
        );
      } catch (e) {
        emit(LocationError(e.toString()));
      }
    });

    on<_LocationDataReceived>((event, emit) {
      emit(LocationSuccess(
        position: event.locationData.position,
        marker: event.locationData.marker,
        cameraPosition: event.locationData.cameraPosition,
        address: event.locationData.address,
      ));
    });

    on<_LocationError>((event, emit) {
      emit(LocationError(event.error));
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
