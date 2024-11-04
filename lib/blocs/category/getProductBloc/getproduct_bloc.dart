import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';

part 'getproduct_event.dart';
part 'getproduct_state.dart';

class GetProductBloc extends Bloc<GetProductEvent, GetProductState> {
  GetProductBloc() : super(GetProductInitial()) {
    on<GetProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(GetProducts event, Emitter<GetProductState> emit) async {
    emit(GetProductLoading());

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      final products = querySnapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();

      //fillter id로 조회 //ismain카테고리 확인해서
      if (event.isMainCategory!) {
        emit(GetProductLoaded(products));
      } else {
        emit(GetProductLoaded(products));
      }
    } catch (e) {
      emit(GetProductError(e.toString()));
    }
  }
}
