import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onlyveyou/blocs/special_bloc/weather/location_bloc.dart';

/// 지도 화면을 담당하는 StatefulWidget
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Bloc 객체 초기화
  late final LocationBloc _locationBloc;

  // Google Maps 컨트롤러
  GoogleMapController? _mapController;

  // 실제 위치 사용 여부 플래그
  bool _isRealLocation = true;

  // 현재 지도 중심 좌표
  LatLng _currentPosition = const LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    // Bloc 객체 초기화
    _locationBloc = context.read<LocationBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LocationBloc, LocationState>(
        bloc: _locationBloc,
        listener: (context, state) {
          // Bloc 상태 변화 감지 및 지도 업데이트
          if (state is LocationSuccess && _mapController != null) {
            setState(() {
              _currentPosition = LatLng(
                state.position.latitude,
                state.position.longitude,
              );
            });
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(state.cameraPosition),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Google Map 위젯
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 15,
                ),
                myLocationEnabled: true, // 사용자 현재 위치 표시
                myLocationButtonEnabled: true, // 현재 위치 버튼 활성화
                markers: state is LocationSuccess
                    ? {state.marker}
                    : {}, // 상태에 따른 마커 표시
                onMapCreated: (controller) {
                  _mapController = controller;
                  _startLocationUpdates();
                },
                onCameraMove: (position) {
                  // 카메라 이동 시 현재 위치 상태 업데이트
                  setState(() {
                    _currentPosition = position.target;
                  });
                },
              ),
              // 위치 정보 및 상태를 표시하는 카드
              if (state is LocationSuccess)
                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '현재 위치',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '위도: ${_currentPosition.latitude.toStringAsFixed(4)}\n'
                            '경도: ${_currentPosition.longitude.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          // 위치 변경 버튼
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _toggleLocation,
                                child: Text(_isRealLocation
                                    ? '서울 기상청으로 이동'
                                    : '현재 위치로 이동'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// 실제 위치와 서울 기상청 위치를 전환
  void _toggleLocation() {
    setState(() {
      _isRealLocation = !_isRealLocation;
      _startLocationUpdates();
    });
  }

  /// 위치 업데이트 시작
  void _startLocationUpdates() {
    if (_isRealLocation) {
      // 현재 위치를 가져오고 위치 업데이트 이벤트 시작
      _locationBloc.add(GetCurrentLocation());
      _locationBloc.add(StartLocationUpdates());
    } else {
      // 서울 기상청 위치로 카메라 이동
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(37.5665, 126.9780),
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Bloc 이벤트 및 Google Map 리소스 해제
    _locationBloc.add(StopLocationUpdates());
    _mapController?.dispose();
    super.dispose();
  }
}
