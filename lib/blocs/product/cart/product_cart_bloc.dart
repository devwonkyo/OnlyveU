import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/product/product_detail_repository.dart';

part 'product_cart_event.dart';
part 'product_cart_state.dart';

// 1. 카트 관련 상태와 이벤트를 별도의 Bloc으로 분리
class ProductCartBloc extends Bloc<ProductCartEvent, ProductCartState> {
  final ProductDetailRepository repository;

  ProductCartBloc({required this.repository}) : super(ProductCartInitial()) {
    on<AddToCartEvent>(_addToCart);
  }

  Future<void> _addToCart(AddToCartEvent event, Emitter<ProductCartState> emit) async {
    try {
      final result = await repository.addToCart(event.productModel);
      if(result.isSuccess){
        emit(AddCartSuccess(result.message ?? "상품이 장바구니에 추가되었습니다."));
      }else{
        emit(AddCartError(result.message ?? "이미 장바구니에 존재하는 상품입니다."));
      }
    } catch (e) {
      emit(AddCartError(e.toString()));
    } finally{
      emit(ProductCartInitial()); // 즉시 초기 상태로 돌아감
    }
  }
}