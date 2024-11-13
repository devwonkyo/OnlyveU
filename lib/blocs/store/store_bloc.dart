import 'package:bloc/bloc.dart';
import 'package:onlyveyou/blocs/store/store_event.dart';
import 'package:onlyveyou/blocs/store/store_state.dart';
import 'package:onlyveyou/models/store_model.dart';
import 'package:onlyveyou/repositories/store/store_repository.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreRepository _repository = StoreRepository();
  StoreBloc() : super(StoreInitial()) {
    on<FetchPickupStore>(_fetchPickupStore);
    on<SelectStore>(_selectStore);
  }

  //매장 정보 다 가져오기
  Future<void> _fetchPickupStore(
      FetchPickupStore event, Emitter<StoreState> emit) async {
    emit(StoreLoading());

    try {
      List<StoreModel> stores = await _repository.getAllStores();
      print("bloc파일에서 store의 값: $stores");
      emit(StoreLoaded(stores));
    } catch (e) {
      emit(StoreError('Failed to fetch store data: ${e.toString()}'));
    }
  }


  //매장 선택
 Future<void> _selectStore(SelectStore event, Emitter<StoreState> emit) async {
    emit(StoreSelected(event.selectedStore));
  }
}
