import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';

part 'getproduct_event.dart';
part 'getproduct_state.dart';

class GetProductBloc extends Bloc<GetProductEvent, GetProductState> {
  GetProductBloc() : super(GetProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<GetProductState> emit) async {
    emit(GetProductLoading());

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      final products = querySnapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();

      if (event.filter != null) {
        emit(GetProductLoaded(products));
      } else {
        emit(GetProductLoaded(products));
      }
    } catch (e) {
      emit(GetProductError(e.toString()));
    }
  }
}
