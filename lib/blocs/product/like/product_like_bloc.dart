import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/product/product_detail_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

part 'product_like_event.dart';
part 'product_like_state.dart';

class ProductLikeBloc extends Bloc<ProductLikeEvent, ProductLikeState> {
  final ProductDetailRepository repository;

  ProductLikeBloc({required this.repository}) : super(ProductLikeInitial()) {
    on<AddToLikeEvent>((event, emit) async {
      try {
        final userId = await OnlyYouSharedPreference().getCurrentUserId();
        await repository.toggleProductLike(userId, event.productId);

        emit(AddLikeSuccess("성공"));
        print("좋아요 성공");
      } catch (e) {
        emit(AddLikeError(e.toString()));
      }finally{
        emit(ProductLikeInitial());
      }
    });
  }





}
