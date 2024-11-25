import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:onlyveyou/repositories/map/goecoding_repository.dart';

part 'store_map_event.dart';
part 'store_map_state.dart';

class StoreMapBloc extends Bloc<StoreMapEvent, StoreMapState> {
  final GeocodingRepository geocodingRepository;

  StoreMapBloc({required this.geocodingRepository}) : super(StoreMapInitial()) {
    on<LoadStoreLocation>(_onLoadStoreLocation);
    on<UpdateMarker>(_onUpdateMarker);
  }

  Future<void> _onLoadStoreLocation(
      LoadStoreLocation event,
      Emitter<StoreMapState> emit,
      ) async {
    emit(StoreMapLoading());
    try {
      final position = await geocodingRepository.getCoordinatesFromAddress(event.address);
      if (position != null) {
        emit(StoreMapLoaded(position));
        print('position : $position');
      } else {
        emit(StoreMapError('주소를 찾을 수 없습니다.'));
      }
    } catch (e) {
      emit(StoreMapError('위치 검색 중 오류가 발생했습니다.'));
    }
  }

  void _onUpdateMarker(UpdateMarker event, Emitter<StoreMapState> emit) {
    emit(StoreMapLoaded(event.position));
  }
}