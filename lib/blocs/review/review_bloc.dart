import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/review_model.dart';
import 'package:onlyveyou/repositories/review/review_repository.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;

  ReviewBloc({required this.repository}) : super(ReviewInitial()) {
    on<LoadReviewListEvent>(_findProductReview);
  }

  Future<void> _findProductReview(LoadReviewListEvent event, Emitter<ReviewState> emit) async {
    try{
      final reviews = await repository.findProductReview(event.productId);
      emit(LoadedReviewState(reviews));
    }catch (e){
      emit(LoadErrorReviewState("error : $e"));
    }

  }
}
