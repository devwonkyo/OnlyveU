import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/product/product_detail_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

part 'category_product_event.dart';
part 'category_product_state.dart';

class CategoryProductBloc extends Bloc<CategoryProductEvent, CategoryProductState> {
  final ProductDetailRepository repository;

  CategoryProductBloc({required this.repository}) : super(CategoryProductInitial()) {
    on<GetProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(GetProducts event, Emitter<CategoryProductState> emit) async {
    emit(CategoryProductLoading());

    try {
      //fillter id로 조회 //ismain카테고리 확인해서
      final products = await repository.getProductsByFilter(
        filter: event.filter!,
        isMainCategory: event.isMainCategory ?? false,
      );

      emit(CategoryProductLoaded(products));
    } catch (e) {
      emit(CategoryProductError(e.toString()));
      print("categroy list error : ${e.toString()}");
    }
  }
}