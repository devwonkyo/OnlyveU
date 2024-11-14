part of 'productdetail_bloc.dart';

abstract class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

//좋아요 눌렀을 때
class ProductLikedSuccess extends ProductDetailState {
  final bool likeState;

  const ProductLikedSuccess(this.likeState);

  @override
  List<Object?> get props => [likeState];
}

class ProductDetailLoaded extends ProductDetailState {
  final ProductModel product;
  final String userId;

  const ProductDetailLoaded(this.product, this.userId);

  @override
  List<Object?> get props => [product, userId];
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object?> get props => [message];
}