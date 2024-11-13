part of 'category_product_bloc.dart';

abstract class CategoryProductState extends Equatable {
  const CategoryProductState();

  @override
  List<Object> get props => [];
}

class CategoryProductInitial extends CategoryProductState {}

class CategoryProductLoading extends CategoryProductState {}

class CategoryProductLoaded extends CategoryProductState {
  final List<ProductModel> products;

  const CategoryProductLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class CategoryProductError extends CategoryProductState {
  final String message;

  const CategoryProductError(this.message);

  @override
  List<Object> get props => [message];
}

