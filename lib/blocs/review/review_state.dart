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
