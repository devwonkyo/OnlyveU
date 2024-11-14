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

  const LoadedReviewState(this.reviewList);

  @override
  List<Object> get props => [reviewList];
}


class LoadErrorReviewState extends ReviewState {
  final String message;

  const LoadErrorReviewState(this.message);

  @override
  List<Object> get props => [message];
}
