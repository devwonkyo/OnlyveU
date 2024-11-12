part of 'product_cart_bloc.dart';

sealed class ProductCartState extends Equatable {
  const ProductCartState();
}

final class ProductCartInitial extends ProductCartState {
  @override
  List<Object> get props => [];
}

class AddCartSuccess extends ProductCartState {
  final String message;

  const AddCartSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AddCartError extends ProductCartState {
  final String message;

  const AddCartError(this.message);

  @override
  List<Object> get props => [message];
}
