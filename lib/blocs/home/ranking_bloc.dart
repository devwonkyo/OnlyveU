// 1. ranking_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/product_repository.dart';

// Events
abstract class RankingEvent {}

class LoadRankingProducts extends RankingEvent {
  final String category;
  LoadRankingProducts({this.category = '전체'});
}

// States
abstract class RankingState {}

class RankingInitial extends RankingState {}

class RankingLoading extends RankingState {}

class RankingLoaded extends RankingState {
  final List<ProductModel> products;
  RankingLoaded(this.products);
}

class RankingError extends RankingState {
  final String message;
  RankingError(this.message);
}

// Bloc
class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final ProductRepository productRepository;

  RankingBloc({required this.productRepository}) : super(RankingInitial()) {
    on<LoadRankingProducts>((event, emit) async {
      emit(RankingLoading());
      try {
        final products =
            await productRepository.getRankingProducts(event.category);
        emit(RankingLoaded(products));
      } catch (e) {
        emit(RankingError('랭킹 상품을 불러오는데 실패했습니다.'));
      }
    });
  }
}
