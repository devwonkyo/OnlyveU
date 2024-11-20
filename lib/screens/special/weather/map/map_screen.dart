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
  late final LocationBloc _locationBloc;
  GoogleMapController? _mapController;
  bool _isRealLocation = true;
  LatLng _currentPosition = const LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    _locationBloc = context.read<LocationBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LocationBloc, LocationState>(
        bloc: _locationBloc,
        listener: (context, state) {
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
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: state is LocationSuccess ? {state.marker} : {},
                onMapCreated: (controller) {
                  _mapController = controller;
                  _startLocationUpdates();
                },
                onCameraMove: (position) {
                  setState(() {
                    _currentPosition = position.target;
                  });
                },
              ),
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

  void _toggleLocation() {
    setState(() {
      _isRealLocation = !_isRealLocation;
      _startLocationUpdates();
    });
  }

  void _startLocationUpdates() {
    if (_isRealLocation) {
      _locationBloc.add(GetCurrentLocation());
      _locationBloc.add(StartLocationUpdates());
    } else {
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
    _locationBloc.add(StopLocationUpdates());
    _mapController?.dispose();
    super.dispose();
  }
}

// 모델이 어떻다... 이런 애기를 - 그게 뭔가 물어볼때. 그걸 내가 다시 지티피에게 물어보는게 중요하다
//  그게 뭔지-> 내 질문을 내가 적어놓자!
//  개념을 자꾸 물어보는 방향으로 사용해보자!
// 책을 보면 당연하게 말하는게- 책을 보면 나올것. ------
// 자신만의 개념을 정립?? = > 지피티가 하라고 하더라고요 ㅠㅠ -> 이거를 명확하게 어떻게 가는지 알아야 한다!
// 구현에 급급한 느낌! ㅠㅠ  -> 책 과목 : 플러터 기본서
// 깡샘 책 보기!
