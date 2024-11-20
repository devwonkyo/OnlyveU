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

  LocationData({
    required this.position,
    required this.marker,
    required this.cameraPosition,
    required this.address,
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      cameraPosition: const CameraPosition(
        target: LatLng(defaultLatitude, defaultLongitude),
        zoom: 15.0,
      ),
      address: '서울특별시 종로구',
    );
  }
}

class LocationRepository {
  static final LocationRepository _instance = LocationRepository._internal();
  factory LocationRepository() => _instance;
  LocationRepository._internal();

  Stream<LocationData>? _locationStream;
  StreamController<LocationData>? _streamController;

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
        return _createLocationData(position, address);
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

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).asyncMap((position) async {
      if (_isInKoreaRegion(position)) {
        final address = await getAddressFromPosition(position);
        return _createLocationData(position, address);
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

    _locationStream = _streamController?.stream;
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
