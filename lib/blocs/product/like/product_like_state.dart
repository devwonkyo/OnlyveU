part of 'product_like_bloc.dart';

sealed class ProductLikeState extends Equatable{
  ProductLikeState();
}

final class ProductLikeInitial extends ProductLikeState {
  @override
  List<Object?> get props => [];
}


class AddLikeSuccess extends ProductLikeState {
  final String message;


  AddLikeSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AddLikeError extends ProductLikeState {
  final String message;

  AddLikeError(this.message);

  @override
  List<Object> get props => [message];
}