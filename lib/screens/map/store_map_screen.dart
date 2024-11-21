import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:onlyveyou/blocs/map/store_map_bloc.dart';
import 'package:onlyveyou/models/store_with_inventory_model.dart';
import 'package:onlyveyou/repositories/map/goecoding_repository.dart';

class StoreMapScreen extends StatefulWidget {
  final StoreWithInventoryModel storeModel;
  const StoreMapScreen({super.key, required this.storeModel});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  NMarker? marker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreMapBloc>().add(
        LoadStoreLocation(widget.storeModel.address),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoreMapBloc, StoreMapState>(
        listener: (context, state) {
          if (state is StoreMapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              children: [
                NaverMap(
                  options: const NaverMapViewOptions(
                    indoorEnable: true,
                    locationButtonEnable: false,
                    consumeSymbolTapEvents: false,
                  ),
                  onMapReady: (controller) async {
                    mapControllerCompleter.complete(controller);
                    if (state is StoreMapLoaded) {
                      print('call storemaploaded');
                      await _updateMarkerAndCamera(state.position);
                    }
                  },
                ),
                if (state is StoreMapLoading)
                  const Center(child: CircularProgressIndicator()),
                _buildBottomSheet(),
              ],
            ),
          );
        },
      );
  }

  Future<void> _updateMarkerAndCamera(NLatLng position) async {
    if (!mounted) return;

    try {
      final controller = await mapControllerCompleter.future;
      await Future.wait([
        if (marker != null) controller.deleteOverlay(marker! as NOverlayInfo),
        controller.addOverlay(
            NMarker(id: 'store-location', position: position)
        ),
        controller.updateCamera(
          NCameraUpdate.withParams(
            target: position,
            zoom: 15,
          ),
        ),
      ]);
    } catch (e) {
      print('Error updating map: $e');
    }
  }

  @override
  void dispose() {
    marker = null;
    super.dispose();
  }

  Widget _buildBottomSheet() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
// 드래그 핸들
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
// 스토어 정보
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
// 스토어 이름과 상태
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.storeModel.storeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.storeModel.isActive ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.storeModel.isActive ? '영업중' : '영업종료',
                          style: TextStyle(
                            color: widget.storeModel.isActive ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
// 주소
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.storeModel.address,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
// 영업시간
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.storeModel.businessHours,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
// 재고 수량
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '재고: ${widget.storeModel.quantity}개',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

