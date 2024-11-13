part of 'product_cart_bloc.dart';


// 카트 이벤트
abstract class ProductCartEvent extends Equatable {
  const ProductCartEvent();
}


// 장 바구니 추가 이벤트
class AddToCartEvent extends ProductCartEvent {
  final ProductModel productModel;

  const AddToCartEvent(this.productModel);

  @override
  List<Object> get props => [productModel];
}