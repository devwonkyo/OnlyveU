import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData {
  static const double defaultLatitude = 37.57142;
  static const double defaultLongitude = 126.9658;

  final Position position;
  final Marker marker;
  final CameraPosition cameraPosition;

  LocationData({
    required this.position,
    required this.marker,
    required this.cameraPosition,
  });

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
      ),
      cameraPosition: const CameraPosition(
        target: LatLng(defaultLatitude, defaultLongitude),
        zoom: 15.0,
      ),
    );
  }
}

class LocationRepository {
  static final LocationRepository _instance = LocationRepository._internal();
  factory LocationRepository() => _instance;
  LocationRepository._internal();

  Stream<LocationData>? _locationStream;
  StreamController<LocationData>? _streamController;

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

  Future<LocationData> getCurrentLocationData() async {
    LocationData defaultLocation = LocationData.defaultLocation();

    try {
      if (!await _checkAndRequestPermission()) {
        return defaultLocation;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (_isInKoreaRegion(position)) {
        return _createLocationData(position);
      }

      return defaultLocation;
    } catch (e) {
      debugPrint('Location error: $e');
      return defaultLocation;
    }
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
      distanceFilter: 10,
      timeLimit: Duration(seconds: 30), // 5초에서 30초로 증가
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (position) {
        if (_isInKoreaRegion(position)) {
          _streamController?.add(_createLocationData(position));
        } else {
          _streamController?.add(LocationData.defaultLocation());
        }
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
        _streamController?.add(LocationData.defaultLocation());
      },
      cancelOnError: false,
    );

    _locationStream = _streamController?.stream;
    return _locationStream!;
  }

  LocationData _createLocationData(Position position) {
    final latLng = LatLng(position.latitude, position.longitude);
    return LocationData(
      position: position,
      marker: Marker(
        markerId: const MarkerId('current_location'),
        position: latLng,
        // 현재 위치이면 빨간색, 기본 위치(기상청)이면 파란색 마커 사용
        icon: position.latitude == LocationData.defaultLatitude &&
                position.longitude == LocationData.defaultLongitude
            ? BitmapDescriptor.defaultMarker
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: position.latitude == LocationData.defaultLatitude &&
                  position.longitude == LocationData.defaultLongitude
              ? '기상청'
              : '현재 위치',
        ),
      ),
      cameraPosition: CameraPosition(
        target: latLng,
        zoom: 15.0,
      ),
    );
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
