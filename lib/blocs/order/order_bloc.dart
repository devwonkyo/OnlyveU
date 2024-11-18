import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/order/order_event.dart';
import 'package:onlyveyou/blocs/order/order_state.dart';
import 'package:onlyveyou/models/available_review_model.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/repositories/order/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository repository;

  OrderBloc(this.repository) : super(OrderInitial()) {
    on<FetchAvailableReviewOrdersEvent>(onFetchOrdersAvailableReview);
  }

  Future<void> onFetchOrdersAvailableReview(FetchAvailableReviewOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final products = await repository.getAvailableReviewOrders();
      final availableReviewOrders = convertToAvailableOrders(products);
      print(availableReviewOrders[0].productId);
      emit(AvailableReviewOrderLoaded(availableReviewOrders));

    } catch (e) {
      emit(AvailableReviewOrderLoaded([]));
    }
  }


  //orders를 ordermodel로 바꾸는것
  List<AvailableOrderModel> convertToAvailableOrders(List<OrderModel> orders) {
    List<AvailableOrderModel> availableOrders = [];

    for (var order in orders) {
      // 각 주문의 모든 아이템에 대해 AvailableOrderModel 생성
      for (var item in order.items) {
        availableOrders.add(
          AvailableOrderModel(
            productId: item.productId,
            orderId: order.id ?? "",
            orderUserId: order.userId,
            orderItem: item,
            purchaseDate: order.createdAt,  // createdAt을 purchaseDate로 사용
            orderType: order.orderType,
          ),
        );
      }
    }

    return availableOrders;
  }
}