part of 'review_bloc.dart';

sealed class ReviewState extends Equatable {
  const ReviewState();
}

final class ReviewInitial extends ReviewState {
  @override
  List<Object> get props => [];
}

class LoadedReviewState extends ReviewState {
  final List<ReviewModel> reviewList;
  final double reviewAverageRating;
  final Map<int, double> reviewRatingPercentAge;

  const LoadedReviewState(this.reviewList, this.reviewAverageRating, this.reviewRatingPercentAge);

  @override
  List<Object> get props => [reviewList, reviewAverageRating, reviewRatingPercentAge];
}

class LoadErrorReviewState extends ReviewState {
  final String message;

  const LoadErrorReviewState(this.message);

  @override
  List<Object> get props => [message];
}

class AddReviewLikeState extends ReviewState {
  final String message;

  const AddReviewLikeState(this.message);

  @override
  List<Object> get props => [message];
}


class LoadingAddReview extends ReviewState {

  const LoadingAddReview();

  @override
  List<Object> get props => [];
}

class SuccessAddReview extends ReviewState {
  final String message;

  const SuccessAddReview(this.message);

  @override
  List<Object> get props => [message];
}

class ErrorAddReview extends ReviewState {
  final String message;

  const ErrorAddReview(this.message);

  @override
  List<Object> get props => [message];
}

class LoadingMyReview extends ReviewState {

  const LoadingMyReview();

  @override
  List<Object> get props => [];
}

class LoadedMyReview extends ReviewState {
  final List<ReviewModel> reviewList;

  const LoadedMyReview(this.reviewList);

  @override
  List<Object> get props => [];
}

class LoadErrorMyReview extends ReviewState {
  final String message;

  const LoadErrorMyReview(this.message);

  @override
  List<Object> get props => [message];
}
