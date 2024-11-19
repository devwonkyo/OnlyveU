import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onlyveyou/blocs/special_bloc/weather/location_bloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // 화면이 생성될 때 위치 정보 요청
    context.read<LocationBloc>().add(GetCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationSuccess) {
            // 위치가 업데이트될 때마다 카메라 이동
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(state.cameraPosition),
            );
          } else if (state is LocationError) {
            // 에러 발생시 스낵바 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LocationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationSuccess) {
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: state.cameraPosition,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: {state.marker},
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // 지도가 생성되면 위치 업데이트 시작
                    context.read<LocationBloc>().add(StartLocationUpdates());
                  },
                ),
                // 날씨 정보를 표시할 오버레이 위젯 (나중에 구현)
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
                            '위도: ${state.position.latitude.toStringAsFixed(4)}\n'
                            '경도: ${state.position.longitude.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('위치 정보를 가져올 수 없습니다.'),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // 화면이 종료될 때 위치 업데이트 중지
    context.read<LocationBloc>().add(StopLocationUpdates());
    _mapController?.dispose();
    super.dispose();
  }
}
