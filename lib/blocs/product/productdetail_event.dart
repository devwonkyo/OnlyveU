part of 'productdetail_bloc.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductDetail extends ProductDetailEvent {
  final String productId;

  const LoadProductDetail(this.productId);

  @override
  List<Object?> get props => [productId];
}

class InputProductHistoryEvent extends ProductDetailEvent {
  final String productId;

  const InputProductHistoryEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}


class TouchProductLikeEvent extends ProductDetailEvent {
  final String productId;

  const TouchProductLikeEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}