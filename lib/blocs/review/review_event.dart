part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class LoadReviewListEvent extends ReviewEvent {
  String productId;

  LoadReviewListEvent(this.productId);

  @override
  List<Object> get props => [productId];
}

class AddReviewLikeEvent extends ReviewEvent {
  String reviewId;
  String userId;

  AddReviewLikeEvent(this.reviewId, this.userId);

  @override
  List<Object> get props => [reviewId, userId];
}

class AddReviewEvent extends ReviewEvent {
  final ReviewModel reviewModel;
  final List<File?> images;
  final String orderId;
  final String orderItemId;

  const AddReviewEvent(
      this.reviewModel, this.images, this.orderId, this.orderItemId);

  @override
  List<Object> get props => [reviewModel, images, orderId, orderItemId];
}

class LoadReviewListWithUserIdEvent extends ReviewEvent {
  const LoadReviewListWithUserIdEvent();

  @override
  List<Object> get props => [];
}

class UpdateReviewEvent extends ReviewEvent {
  final ReviewModel reviewModel;
  final List<String?> images;

  const UpdateReviewEvent(this.reviewModel, this.images);

  @override
  List<Object> get props => [reviewModel, images];
}
