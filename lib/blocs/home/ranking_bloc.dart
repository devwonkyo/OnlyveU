// ranking_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/product_repository.dart';

// Events
abstract class RankingEvent {}

class LoadRankingProducts extends RankingEvent {
  final String? categoryId;
  LoadRankingProducts({this.categoryId});
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
        print(
            'Loading products with categoryId: ${event.categoryId}'); // 디버그 로그
        final products =
            await productRepository.getRankingProducts(event.categoryId);
        print('Loaded ${products.length} products'); // 로드된 상품 개수

        if (products.isEmpty) {
          emit(RankingError('상품이 없습니다.'));
        } else {
          emit(RankingLoaded(products));
        }
      } catch (e) {
        print('Error in RankingBloc: $e'); // 에러 로그
        emit(RankingError('랭킹 상품을 불러오는데 실패했습니다.'));
      }
    });
  }
}
