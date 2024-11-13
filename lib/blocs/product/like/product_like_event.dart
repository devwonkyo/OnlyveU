part of 'product_like_bloc.dart';

// 좋아요 이벤트
abstract class ProductLikeEvent extends Equatable {
  const ProductLikeEvent();
}



class AddToLikeEvent extends ProductLikeEvent {
  final String productId;
  final String userId;


  AddToLikeEvent({required this.userId, required this.productId});

  @override
  List<Object> get props => [productId, userId];
}

