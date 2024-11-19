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
  bool _initialLocationSet = false;

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
            if (!_initialLocationSet) {
              _mapController
                  ?.moveCamera(
                CameraUpdate.newCameraPosition(state.cameraPosition),
              )
                  .then((_) {
                setState(() => _initialLocationSet = true);
              }).catchError((e) {
                debugPrint('Camera movement failed: $e');
              });
            } else {
              _mapController
                  ?.animateCamera(
                CameraUpdate.newCameraPosition(state.cameraPosition),
              )
                  .catchError((e) {
                debugPrint('Camera animation failed: $e');
              });
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.5665, 126.9780),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: state is LocationSuccess ? {state.marker} : {},
                onMapCreated: (controller) {
                  _mapController = controller;
                  _locationBloc
                    ..add(GetCurrentLocation())
                    ..add(StartLocationUpdates());
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
                            '위도: ${state.position.latitude.toStringAsFixed(4)}\n'
                            '경도: ${state.position.longitude.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (state is LocationLoading)
                const Center(child: CircularProgressIndicator()),
              if (state is LocationError) Center(child: Text(state.message)),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _locationBloc.add(StopLocationUpdates());
    _mapController?.dispose();
    super.dispose();
  }
}
