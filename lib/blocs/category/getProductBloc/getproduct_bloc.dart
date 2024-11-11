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
      //fillter id로 조회 //ismain카테고리 확인해서
      if (event.isMainCategory!) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('categoryId', isEqualTo: event.filter)  // categoryId가 event.filter와 같은 것만
            .get();

        final products = querySnapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
        emit(GetProductLoaded(products));
      } else {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('subcategoryId', isEqualTo: event.filter)  // categoryId가 event.filter와 같은 것만
            .get();

        final products = querySnapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
        emit(GetProductLoaded(products));
      }
    } catch (e) {
      emit(GetProductError(e.toString()));
      print("categroy list error : ${e.toString()}");
    }
  }
}
