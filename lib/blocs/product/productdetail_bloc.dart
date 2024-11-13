import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/product/product_detail_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

part 'productdetail_event.dart';
part 'productdetail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductDetailRepository repository;

  ProductDetailBloc(this.repository) : super(ProductDetailInitial()) {
    on<LoadProductDetail>(_onLoadProductDetail);
    on<InputProductHistoryEvent>(_inputProductHistory);
    on<TouchProductLikeEvent>(_touchProductLikeButton);
  }

  Future<void> _onLoadProductDetail(LoadProductDetail event, Emitter<ProductDetailState> emit) async {
    emit(ProductDetailLoading());
    try {
      final product = await repository.getProductById(event.productId);
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      if(product != null){
        emit(ProductDetailLoaded(product,userId));
      }else{
        emit(ProductDetailError("제품을 가져오지 못했습니다."));
      }
    } catch (e) {
      emit(ProductDetailError(e.toString()));
    }
  }

  Future<void> _inputProductHistory(InputProductHistoryEvent event, Emitter<ProductDetailState> emit) async {
    try {
      await repository.updateUserViewHistory(event.productId);
    } catch (e) {
      emit(ProductDetailError(e.toString()));
    }
  }


  Future<void> _touchProductLikeButton(TouchProductLikeEvent event, Emitter<ProductDetailState> emit) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final likeProduct = await repository.touchProductLike(event.productId);
      emit(ProductLikedSuccess(likeProduct.likeState));
      emit(ProductDetailLoaded(likeProduct.likeProduct,userId));
    } catch (e) {
      emit(ProductDetailError(e.toString()));
    }
  }

}