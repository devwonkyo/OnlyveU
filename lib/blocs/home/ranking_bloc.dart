import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/home/ranking_repository.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';

// import 변경
//event
// RankingEvent: 랭킹 상품 로드 이벤트 정의
abstract class RankingEvent {}

// 특정 카테고리의 랭킹 상품을 로드하는 이벤트
class LoadRankingProducts extends RankingEvent {
  final String? categoryId; // 카테고리 ID (필수 아님)
  LoadRankingProducts({this.categoryId});
}

//좋아요랑 상품연결
class ToggleRankingFavorite extends RankingEvent {
  final ProductModel product;
  final String userId;
  ToggleRankingFavorite(this.product, this.userId);
}

// 좋아요랑 유저 연결
class ToggleProductFavorite extends RankingEvent {
  final ProductModel product;
  final String userId;
  ToggleProductFavorite(this.product, this.userId);
}

//장바구니집어넣기
class AddToCart extends RankingEvent {
  final String productId;
  AddToCart(this.productId); // userId 제거 (HomeBloc과 동일하게)
}

/////stste
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

//RankingState에 성공 상태 추가: 장바구니 추가
class RankingSuccess extends RankingState {
  final String message;
  RankingSuccess(this.message);
} //장바구니 중복 처리

class RankingError extends RankingState {
  // 추가
  final String message;
  RankingError(this.message);
}

// 오류 상태: 상품 로드 중 오류가 발생한 경우 표시되는 상태
class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final RankingRepository _rankingRepository;
  final ShoppingCartRepository _cartRepository; // 추가

  RankingBloc({
    required RankingRepository rankingRepository,
    required ShoppingCartRepository cartRepository, // 추가
  })  : _rankingRepository = rankingRepository,
        _cartRepository = cartRepository, // 추가
        super(RankingInitial()) {
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

    //좋아요 토글 기능
    on<ToggleProductFavorite>((event, emit) async {
      if (state is RankingLoaded) {
        final currentState = state as RankingLoaded;
        try {
          await rankingRepository.toggleProductFavorite(
              event.product.productId, event.userId);

          final updatedProducts = currentState.products.map((product) {
            if (product.productId == event.product.productId) {
              List<String> updatedFavoriteList =
                  List<String>.from(product.favoriteList);
              if (updatedFavoriteList.contains(event.userId)) {
                updatedFavoriteList.remove(event.userId);
              } else {
                updatedFavoriteList.add(event.userId);
              }
              return product.copyWith(favoriteList: updatedFavoriteList);
            }
            return product;
          }).toList();

          emit(RankingLoaded(updatedProducts));
        } catch (e) {
          print('Error toggling favorite in RankingBloc: $e');
        }
      }
    }); //^
    // 장바구니 넣기
    on<AddToCart>((event, emit) async {
      if (state is RankingLoaded) {
        final currentState = state as RankingLoaded;
        try {
          await _cartRepository.addToCart(event.productId);
          emit(RankingSuccess('장바구니에 담겼습니다.')); // 성공 메시지
          emit(currentState);
        } catch (e) {
          emit(RankingError(e.toString()));
          emit(currentState);
        }
      }
    });
  }
}
