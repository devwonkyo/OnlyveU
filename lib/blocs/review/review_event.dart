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

class AddReviewLikeEvent extends ReviewEvent{
  String reviewId;
  String userId;

  AddReviewLikeEvent(this.reviewId, this.userId);

  @override
  List<Object> get props => [reviewId, userId];
}


class AddReviewEvent extends ReviewEvent{
  final ReviewModel reviewModel;

  const AddReviewEvent(this.reviewModel);

  @override
  List<Object> get props => [reviewModel];
}
