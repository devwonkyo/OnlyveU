// today_sale_bloc.dart
//UI -> Bloc -> Repository -> Firestore -> Repository -> Bloc -> UI 이렇게
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/home/today_sale_repository.dart';

// TodaySaleEvent: 특가 상품 로딩 및 섞기 이벤트 정의
abstract class TodaySaleEvent {}

// 특가 상품 로딩 이벤트
class LoadTodaySaleProducts extends TodaySaleEvent {}

// 특가 상품 목록 섞기 이벤트
class ShuffleProducts extends TodaySaleEvent {}

//좋아요 이벤트
class ToggleProductFavorite extends TodaySaleEvent {
  final ProductModel product;
  final String userId;
  ToggleProductFavorite(this.product, this.userId);
}

//장바구니 담기
class AddToCart extends TodaySaleEvent {
  final String productId;
  final String userId;
  AddToCart(this.productId, this.userId);
}

// TodaySaleState: 특가 상품 로딩의 상태 정의
abstract class TodaySaleState {}

// 초기 상태: Bloc이 시작할 때 기본 상태
class TodaySaleInitial extends TodaySaleState {}

// 로딩 상태: 특가 상품이 로딩 중일 때 사용
class TodaySaleLoading extends TodaySaleState {}

// 로딩 완료 상태: 특가 상품이 성공적으로 로딩된 상태, 상품 목록 포함
class TodaySaleLoaded extends TodaySaleState {
  final List<ProductModel> products;
  TodaySaleLoaded(this.products);
}

// 오류 상태: 로딩 중 오류가 발생했을 때 메시지를 포함한 상태
class TodaySaleError extends TodaySaleState {
  final String message;
  TodaySaleError(this.message);
}

// TodaySaleBloc: 특가 상품 로딩 및 섞기 기능을 위한 Bloc 클래스
class TodaySaleBloc extends Bloc<TodaySaleEvent, TodaySaleState> {
  final TodaySaleRepository repository; // 데이터 로딩에 사용할 리포지토리 인스턴스

  TodaySaleBloc({required this.repository}) : super(TodaySaleInitial()) {
    // 특가 상품 로딩 이벤트 처리
    on<LoadTodaySaleProducts>((event, emit) async {
      emit(TodaySaleLoading()); // 로딩 상태로 전환
      try {
        final products = await repository.getTodaySaleProducts(); // 상품 데이터 가져오기
        emit(TodaySaleLoaded(products)); // 로딩 완료 상태로 전환
      } catch (e) {
        print('Error loading today sale products: $e');
        emit(TodaySaleError('특가 상품을 불러오는데 실패했습니다.')); // 오류 상태로 전환
      }
    });

    // 상품 목록 섞기 이벤트 처리
    on<ShuffleProducts>((event, emit) async {
      if (state is TodaySaleLoaded) {
        final currentState = state as TodaySaleLoaded;
        final shuffledProducts = List<ProductModel>.from(currentState.products)
          ..shuffle(); // 상품 목록 섞기
        print(
            'Products shuffled. New order length: ${shuffledProducts.length}');
        emit(TodaySaleLoaded(shuffledProducts)); // 섞인 상품 목록으로 상태 갱신
      }
    });
    //좋아요 토글
    on<ToggleProductFavorite>((event, emit) async {
      if (state is TodaySaleLoaded) {
        final currentState = state as TodaySaleLoaded;
        try {
          await repository.toggleProductFavorite(
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

          emit(TodaySaleLoaded(updatedProducts));
        } catch (e) {
          print('Error toggling favorite in TodaySaleBloc: $e');
        }
      }
    });
    //장바구니 추가
    on<AddToCart>((event, emit) async {
      try {
        await repository.addToCart(event.productId, event.userId);
      } catch (e) {
        print('Error adding to cart: $e');
      }
    });
  }
}
