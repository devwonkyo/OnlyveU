// location_repository.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData {
  static const double defaultLatitude = 37.57142;
  static const double defaultLongitude = 126.9658;

  final Position position;
  final Marker marker;
  final CameraPosition cameraPosition;
  final String address;
  final DateTime timestamp; // 타임스탬프 추가

  LocationData({
    required this.position,
    required this.marker,
    required this.cameraPosition,
    required this.address,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory LocationData.defaultLocation() {
    final position = Position(
      latitude: defaultLatitude,
      longitude: defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    return LocationData(
      position: position,
      marker: Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(defaultLatitude, defaultLongitude),
        infoWindow: const InfoWindow(title: '기상청'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      cameraPosition: const CameraPosition(
        target: LatLng(defaultLatitude, defaultLongitude),
        zoom: 15.0,
      ),
      address: '서울특별시 종로구',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        position.latitude == other.position.latitude &&
        position.longitude == other.position.longitude;
  }

  @override
  int get hashCode => position.latitude.hashCode ^ position.longitude.hashCode;
}

class LocationRepository {
  static final LocationRepository _instance = LocationRepository._internal();
  factory LocationRepository() => _instance;
  LocationRepository._internal();

  Stream<LocationData>? _locationStream;
  StreamController<LocationData>? _streamController;
  LocationData? _lastLocationData;
  final Duration _minUpdateInterval = const Duration(seconds: 30);

  Future<String> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.administrativeArea ?? ''} ${place.subLocality ?? ''}'
                .trim();
        return address.isEmpty ? '주소를 찾을 수 없습니다' : address;
      }
      return '주소를 찾을 수 없습니다';
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return '주소 변환 중 오류 발생';
    }
  }

  Future<LocationData> getCurrentLocationData() async {
    try {
      if (!await _checkAndRequestPermission()) {
        return LocationData.defaultLocation();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (_isInKoreaRegion(position)) {
        final address = await getAddressFromPosition(position);
        final locationData = await _createLocationData(position, address);
        _lastLocationData = locationData;
        return locationData;
      }

      return LocationData.defaultLocation();
    } catch (e) {
      debugPrint('Location error: $e');
      return LocationData.defaultLocation();
    }
  }

  Stream<LocationData> getLocationDataStream() {
    if (_locationStream != null) {
      return _locationStream!;
    }

    _streamController = StreamController<LocationData>.broadcast(
      onCancel: () {
        _streamController?.close();
        _streamController = null;
        _locationStream = null;
      },
    );

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 30, // 30미터 이상 이동했을 때만 업데이트
      timeLimit: Duration(seconds: 60), // 60초마다 업데이트
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .distinct() // 중복 위치 필터링
        .asyncMap((position) async {
      // 마지막 업데이트 이후 최소 간격 체크
      if (_lastLocationData != null) {
        final timeSinceLastUpdate =
            DateTime.now().difference(_lastLocationData!.timestamp);
        if (timeSinceLastUpdate < _minUpdateInterval) {
          return _lastLocationData!;
        }
      }

      if (_isInKoreaRegion(position)) {
        final address = await getAddressFromPosition(position);
        final locationData = await _createLocationData(position, address);
        _lastLocationData = locationData;
        return locationData;
      }
      return LocationData.defaultLocation();
    }).listen(
      (locationData) => _streamController?.add(locationData),
      onError: (error) {
        debugPrint('Location stream error: $error');
        _streamController?.add(LocationData.defaultLocation());
      },
      cancelOnError: false,
    );

    _locationStream = _streamController?.stream.distinct();
    return _locationStream!;
  }

  LocationData _createLocationData(Position position, String address) {
    final latLng = LatLng(position.latitude, position.longitude);
    return LocationData(
      position: position,
      marker: Marker(
        markerId: const MarkerId('current_location'),
        position: latLng,
        icon: position.latitude == LocationData.defaultLatitude &&
                position.longitude == LocationData.defaultLongitude
            ? BitmapDescriptor.defaultMarker
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: position.latitude == LocationData.defaultLatitude &&
                  position.longitude == LocationData.defaultLongitude
              ? '기상청'
              : address,
        ),
      ),
      cameraPosition: CameraPosition(
        target: latLng,
        zoom: 15.0,
      ),
      address: address,
    );
  }

  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    return permission != LocationPermission.deniedForever;
  }

  Future<bool> checkLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      }
      return serviceEnabled;
    } on PlatformException catch (e) {
      debugPrint('위치 서비스 초기화 실패: $e');
      return false;
    }
  }

  bool _isInKoreaRegion(Position position) {
    const double minLat = 33.0;
    const double maxLat = 38.5;
    const double minLng = 125.0;
    const double maxLng = 132.0;

    return position.latitude >= minLat &&
        position.latitude <= maxLat &&
        position.longitude >= minLng &&
        position.longitude <= maxLng;
  }

  void dispose() {
    _streamController?.close();
    _streamController = null;
    _locationStream = null;
  }
}
