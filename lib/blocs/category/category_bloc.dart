import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<GetProducts>(_onGetProducts);
  }

  Future<void> _onGetProducts(GetProducts event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      final products = querySnapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();

      if (event.filter != null) {
        emit(CategoryLoaded(products));
      } else {
        emit(CategoryLoaded(products));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
