import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/home/ranking_repository.dart';
// import 변경

// RankingEvent: 랭킹 상품 로드 이벤트 정의
abstract class RankingEvent {}

// 특정 카테고리의 랭킹 상품을 로드하는 이벤트
class LoadRankingProducts extends RankingEvent {
  final String? categoryId; // 카테고리 ID (필수 아님)
  LoadRankingProducts({this.categoryId});
}

// RankingState: 랭킹 상품 로드 상태 정의
abstract class RankingState {}

// 초기 상태: Bloc 초기 상태
class RankingInitial extends RankingState {}

// 로딩 상태: 랭킹 상품을 로드하는 중일 때 표시되는 상태
class RankingLoading extends RankingState {}

// 로드 완료 상태: 랭킹 상품이 성공적으로 로드된 상태, 상품 목록 포함
class RankingLoaded extends RankingState {
  final List<ProductModel> products;
  RankingLoaded(this.products);
}

// 오류 상태: 상품 로드 중 오류가 발생한 경우 표시되는 상태
class RankingError extends RankingState {
  final String message;
  RankingError(this.message);
}

// RankingBloc: 랭킹 상품 로드 및 상태 관리를 위한 Bloc 클래스
class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final RankingRepository rankingRepository; // 랭킹 상품 데이터를 가져오는 데 사용할 리포지토리 인스턴스

  RankingBloc({required this.rankingRepository}) : super(RankingInitial()) {
    // LoadRankingProducts 이벤트 처리
    on<LoadRankingProducts>((event, emit) async {
      emit(RankingLoading()); // 로딩 상태로 전환
      try {
        print('Loading products with categoryId: ${event.categoryId}');

        // 카테고리 ID가 있으면 해당 카테고리의 랭킹 상품 로드
        final products =
            await rankingRepository.getRankingProducts(event.categoryId);

        print('Loaded ${products.length} products');

        if (products.isEmpty) {
          emit(RankingError('상품이 없습니다.')); // 상품이 없는 경우 오류 상태로 전환
        } else {
          emit(RankingLoaded(products)); // 로드 완료 상태로 전환
        }
      } catch (e) {
        print('Error in RankingBloc: $e');
        emit(RankingError('랭킹 상품을 불러오는데 실패했습니다.')); // 오류 발생 시 오류 상태로 전환
      }
    });
  }
}
