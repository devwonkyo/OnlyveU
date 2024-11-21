import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../repositories/special/weather/location_repository.dart';

// Public Events
// 외부에서 사용할 수 있는 위치 관련 이벤트 정의
abstract class LocationEvent {}

/// 현재 위치를 요청하는 이벤트
class GetCurrentLocation extends LocationEvent {}

/// 위치 업데이트를 시작하는 이벤트
class StartLocationUpdates extends LocationEvent {}

/// 위치 업데이트를 중단하는 이벤트
class StopLocationUpdates extends LocationEvent {}

// Internal Events
// 내부에서 사용되는 위치 관련 이벤트 정의

/// 위치 데이터를 성공적으로 수신했을 때 발생하는 내부 이벤트
class _LocationDataReceived extends LocationEvent {
  final LocationData locationData; // 수신된 위치 데이터
  _LocationDataReceived(this.locationData); // 생성자
}

/// 위치 데이터 수신 중 에러가 발생했을 때 발생하는 내부 이벤트
class _LocationError extends LocationEvent {
  final String error; // 에러 메시지
  _LocationError(this.error); // 생성자
}

// States
// 위치 관련 Bloc의 상태 정의
abstract class LocationState {}

/// Bloc 초기 상태
class LocationInitial extends LocationState {}

/// 위치 정보를 로드 중인 상태
class LocationLoading extends LocationState {}

/// 위치 정보를 성공적으로 가져온 상태
class LocationSuccess extends LocationState {
  final Position position; // GPS 위치 정보
  final Marker marker; // 지도에 표시할 마커
  final CameraPosition cameraPosition; // Google Maps 카메라 위치
  final String address; // 위치를 기반으로 얻은 주소 정보

  LocationSuccess({
    required this.position,
    required this.marker,
    required this.cameraPosition,
    required this.address,
  });

  /// 현재 상태를 기반으로 새로운 상태 객체를 생성하는 메서드
  LocationSuccess copyWith({
    Position? position,
    Marker? marker,
    CameraPosition? cameraPosition,
    String? address,
  }) {
    return LocationSuccess(
      position: position ?? this.position, // 기존 위치 정보 유지
      marker: marker ?? this.marker, // 기존 마커 유지
      cameraPosition: cameraPosition ?? this.cameraPosition, // 기존 카메라 위치 유지
      address: address ?? this.address, // 기존 주소 유지
    );
  }
}

/// 위치 정보를 가져오는데 실패한 상태
class LocationError extends LocationState {
  final String message; // 에러 메시지
  LocationError(this.message); // 생성자
}

// Bloc 정의
// 위치 관련 상태를 관리하고 이벤트를 처리하는 Bloc
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _repository; // 위치 데이터를 제공하는 리포지토리
  StreamSubscription<LocationData>? _locationSubscription; // 위치 데이터 스트림 구독

  LocationBloc({required LocationRepository repository})
      : _repository = repository, // 리포지토리 초기화
        super(LocationInitial()) {
    // GetCurrentLocation 이벤트 처리
    on<GetCurrentLocation>((event, emit) async {
      try {
        emit(LocationLoading()); // 로딩 상태로 전환
        final locationData =
            await _repository.getCurrentLocationData(); // 위치 데이터 요청

        if (!isClosed) {
          emit(LocationSuccess(
            position: locationData.position, // 위치 정보
            marker: locationData.marker, // 마커 정보
            cameraPosition: locationData.cameraPosition, // 카메라 위치 정보
            address: locationData.address, // 주소 정보
          )); // 성공 상태로 전환
        }
      } catch (e) {
        if (!isClosed) {
          emit(LocationError(
              '위치 정보를 가져오는데 실패했습니다: ${e.toString()}')); // 에러 상태 전환
        }
      }
    });

    // StartLocationUpdates 이벤트 처리
    on<StartLocationUpdates>((event, emit) async {
      await _locationSubscription?.cancel(); // 기존 구독 취소
      emit(LocationLoading()); // 로딩 상태로 전환

      try {
        if (!await _repository.checkLocationService()) {
          emit(LocationError("위치 서비스를 활성화해주세요")); // 위치 서비스 비활성화 에러
          return;
        }

        // 위치 데이터 스트림 구독 시작
        _locationSubscription = _repository.getLocationDataStream().listen(
          (locationData) {
            if (!isClosed) {
              add(_LocationDataReceived(locationData)); // 위치 데이터 수신 이벤트 추가
            }
          },
          onError: (error) {
            if (!isClosed) {
              add(_LocationError(error.toString())); // 위치 데이터 에러 이벤트 추가
            }
          },
        );
      } catch (e) {
        emit(LocationError(e.toString())); // 에러 상태 전환
      }
    });

    // _LocationDataReceived 이벤트 처리
    on<_LocationDataReceived>((event, emit) {
      emit(LocationSuccess(
        position: event.locationData.position, // 위치 정보
        marker: event.locationData.marker, // 마커 정보
        cameraPosition: event.locationData.cameraPosition, // 카메라 위치 정보
        address: event.locationData.address, // 주소 정보
      )); // 성공 상태로 전환
    });

    // _LocationError 이벤트 처리
    on<_LocationError>((event, emit) {
      emit(LocationError(event.error)); // 에러 상태로 전환
    });

    // StopLocationUpdates 이벤트 처리
    on<StopLocationUpdates>((event, emit) async {
      await _locationSubscription?.cancel(); // 구독 취소
      _locationSubscription = null; // 구독 객체 초기화
    });
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel(); // Bloc 종료 시 구독 취소
    return super.close(); // Bloc 종료
  }
}
