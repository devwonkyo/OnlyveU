import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/review_model.dart';
import 'package:onlyveyou/repositories/review/review_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;

  ReviewBloc({required this.repository}) : super(ReviewInitial()) {
    on<LoadReviewListEvent>(_findProductReview);
    on<AddReviewLikeEvent>(_addLikeReview);
    on<AddReviewEvent>(_addReview);
    on<UpdateReviewEvent>(_updateReview);
    on<LoadReviewListWithUserIdEvent>(_findMyReview);
  }

  Future<void> _findProductReview(LoadReviewListEvent event, Emitter<ReviewState> emit) async {
    try{
      final reviews = await repository.findProductReview(event.productId);
      final reviewsAverageRaging = calculateAverageRating(reviews);
      final reviewsRatingPercentages = calculateRatingPercentages(reviews);
      emit(LoadedReviewState(reviews, reviewsAverageRaging, reviewsRatingPercentages));
    }catch (e){
      emit(LoadErrorReviewState("error : $e"));
    }
  }

  Future<void> _addLikeReview(AddReviewLikeEvent event, Emitter<ReviewState> emit) async {
    try{
      await repository.addLikeReview(event.reviewId, event.userId);
      emit(AddReviewLikeState("조아요"));
    }catch(e){
      emit(LoadErrorReviewState("error : $e"));
    }
  }


  Future<void> _addReview(AddReviewEvent event, Emitter<ReviewState> emit) async {
    try{
      emit(LoadingAddReview());
      await repository.addReview(event.reviewModel, event.images, event.orderId, event.orderItemId);
      print('업로드 완료');
      emit(SuccessAddReview("업로드 햇씁니당"));
    }catch(e){
      print('업로드 에러 : $e');
      emit(ErrorAddReview("error : $e"));
    }
  }

  Future<void> _findMyReview(LoadReviewListWithUserIdEvent event, Emitter<ReviewState> emit) async {
    try{
      emit(const LoadingMyReview());

      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final reviews = await repository.findMyReview(userId);

      emit(LoadedMyReview(reviews));
    }catch (e){
      emit(LoadErrorMyReview("error : $e"));
    }
  }

  Future<void> _updateReview(UpdateReviewEvent event, Emitter<ReviewState> emit) async {
    try{
      emit(LoadingUpdateReview());
      await repository.updateReview(event.reviewModel, event.images);
      print('업데이트 완료');
      emit(SuccessUpdateReview("업데이트 햇씁니당"));
    }catch(e){
      print('업로드 에러 : $e');
      emit(ErrorUpdateReview("error : $e"));
    }
  }




  //평점 구하기
  double calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0.0;

    double totalScore = reviews.fold(0.0, (sum, review) => sum + review.rating);
    double average = totalScore / reviews.length;

    // 소수점 1자리까지 반올림
    return double.parse(average.toStringAsFixed(1));
  }

  // 1~5 점수 별 비율 계산
  Map<int, double> calculateRatingPercentages(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return {for (int i = 1; i <= 5; i++) i: 0.0};
    }

    int totalReviews = reviews.length;
    Map<int, int> ratingCounts = {for (int i = 1; i <= 5; i++) i: 0};

    // 각 점수별 개수 카운트
    for (var review in reviews) {
      int roundedRating = review.rating.round(); // 평점이 1~5로 한정된 경우 사용
      if (ratingCounts.containsKey(roundedRating)) {
        ratingCounts[roundedRating] = ratingCounts[roundedRating]! + 1;
      }
    }

    // 비율 계산
    return {
      for (int i = 1; i <= 5; i++)
        i: (ratingCounts[i]! / totalReviews) // 100을 곱하지 않고 비율만 반환
    };
  }


}
