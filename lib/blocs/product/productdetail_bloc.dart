import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/product/product_detail_repository.dart';

part 'productdetail_event.dart';
part 'productdetail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductDetailRepository repository;

  ProductDetailBloc(this.repository) : super(ProductDetailInitial()) {
    on<LoadProductDetail>(_onLoadProductDetail);
  }

  Future<void> _onLoadProductDetail(LoadProductDetail event, Emitter<ProductDetailState> emit) async {
    emit(ProductDetailLoading());
    try {
      final product = await repository.getProductById(event.productId);

      if(product != null){
        emit(ProductDetailLoaded(product));
      }else{
        emit(ProductDetailError("제품을 가져오지 못했습니다."));
      }
    } catch (e) {
      emit(ProductDetailError(e.toString()));
    }
  }
}