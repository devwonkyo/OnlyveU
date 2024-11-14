part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class LoadReviewListEvent extends ReviewEvent{
  String productId;

  LoadReviewListEvent(this.productId);

  @override
  List<Object> get props => [productId];
}
