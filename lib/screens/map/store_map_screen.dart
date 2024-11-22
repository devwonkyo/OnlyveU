import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:onlyveyou/blocs/map/store_map_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/store_with_inventory_model.dart';
import 'package:onlyveyou/repositories/map/goecoding_repository.dart';
import 'package:onlyveyou/widgets/cartItmes_appbar.dart';

class StoreMapScreen extends StatefulWidget {
  final StoreWithInventoryModel storeModel;
  const StoreMapScreen({super.key, required this.storeModel});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  bool _isInitialized = false;
  NMarker? marker;
  late final StoreMapBloc _mapBloc;  // BLoC 인스턴스 저장

  @override
  void initState() {
    super.initState();
    _mapBloc = StoreMapBloc(geocodingRepository: GeocodingRepository());  // BLoC 초기화
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (_isInitialized) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    _mapBloc.add(LoadStoreLocation(widget.storeModel.address));  // 저장된 BLoC 인스턴스 사용
    _isInitialized = true;
  }

  @override
  void dispose() {
    _mapBloc.close();  // BLoC 정리
    marker = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(  // BlocProvider.value 사용
      value: _mapBloc,  // 기존 BLoC 인스턴스 전달
      child: BlocConsumer<StoreMapBloc, StoreMapState>(
        listener: (context, state) {
          if (state is StoreMapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is StoreMapLoaded) {
            _updateMarkerAndCamera(state.position);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: const CartItemsAppBar(
              appTitle: '매장 위치 찾기',
            ),
            body: Stack(
              children: [
                NaverMap(
                  options: const NaverMapViewOptions(
                    indoorEnable: true,
                    locationButtonEnable: false,
                    consumeSymbolTapEvents: false,
                  ),
                  onMapReady: (controller) {
                    mapControllerCompleter.complete(controller);
                  },
                ),
                if (state is StoreMapLoading)
                  const Center(child: CircularProgressIndicator()),
                _buildBottomSheet(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateMarkerAndCamera(NLatLng position) async {
    try {
      final controller = await mapControllerCompleter.future;

      // 1. 기존 마커 삭제
      if (marker != null) {
        await controller.deleteOverlay(marker! as NOverlayInfo);
        marker = null;
      }

      // 2. 새 마커 생성 및 추가
      marker = NMarker(
        id: 'store-location',
        position: position,
      );

      final iconWidget = Center(
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppsColor.pastelGreen,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),  // padding 조정
          child: Icon(
            Icons.spa,
            color: AppsColor.pastelGreen,
            size: 22,  // 크기 미세 조정
          ),
        ),
      );

// 위젯을 이미지로 변환할 때도 동일한 크기 사용
      final overlay = await NOverlayImage.fromWidget(
        widget: iconWidget,
        size: const Size(40, 40),
        context: context,
      );

      marker!.setIcon(overlay);

// 캡션(상점 이름) 설정
      marker!.setCaption(
        NOverlayCaption(
          text: widget.storeModel.storeName,
          textSize: 14,
          color: Colors.black,
          haloColor: Colors.white,  // 텍스트 테두리 색상
        ),
      );

      await controller.addOverlay(marker!);

      // 3. 카메라 이동
      await controller.updateCamera(
        NCameraUpdate.withParams(
          target: position,
          zoom: 15,
        ),
      );
    } catch (e) {
      print('Error updating map: $e');
    }
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

