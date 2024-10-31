part of 'getproduct_bloc.dart';

// get_product_state.dart
abstract class GetProductState extends Equatable {
  const GetProductState();

  @override
  List<Object> get props => [];
}

class GetProductInitial extends GetProductState {}

class GetProductLoading extends GetProductState {}

class GetProductLoaded extends GetProductState {
  final List<ProductModel> products;

  const GetProductLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class GetProductError extends GetProductState {
  final String message;

  const GetProductError(this.message);

  @override
  List<Object> get props => [message];
}