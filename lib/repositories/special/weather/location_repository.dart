import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationRepository {
  // 싱글톤 패턴 구현
  static final LocationRepository _instance = LocationRepository._internal();
  factory LocationRepository() => _instance;
  LocationRepository._internal();

  // 위치 권한 체크 및 요청
  Future<bool> checkAndRequestPermission() async {
    // 현재 권한 상태 체크
    final status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    }

    // 권한이 없으면 요청
    final result = await Permission.location.request();
    return result.isGranted;
  }

  // 위치 서비스 활성화 체크 및 요청
  Future<bool> checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // 위치 서비스가 꺼져있으면 설정으로 이동
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    return serviceEnabled;
  }

  // 현재 위치 가져오기
  Future<Position> getCurrentLocation() async {
    try {
      // 권한 체크
      bool hasPermission = await checkAndRequestPermission();
      bool serviceEnabled = await checkLocationService();

      if (!hasPermission || !serviceEnabled) {
        throw Exception('Location permissions are required');
      }

      // 현재 위치 반환
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  // 위치 변경 스트림 제공
  Stream<Position> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // 10미터마다 업데이트
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Position을 LatLng로 변환 (구글맵용)
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }

  // 마커 생성
  Marker createLocationMarker(LatLng position) {
    return Marker(
      markerId: const MarkerId('current_location'),
      position: position,
      infoWindow: const InfoWindow(title: '현재 위치'),
    );
  }

  // 카메라 위치 업데이트
  CameraPosition updateCameraPosition(LatLng position) {
    return CameraPosition(
      target: position,
      zoom: 15.0,
    );
  }
}
