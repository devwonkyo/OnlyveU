import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/order/order_event.dart';
import 'package:onlyveyou/blocs/order/order_state.dart';
import 'package:onlyveyou/repositories/order/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository repository;

  OrderBloc(this.repository) : super(OrderInitial()) {
    on<FetchOrdersEvent>(onFetchOrdersAvailableReview);
  }

  Future<void> onFetchOrdersAvailableReview(FetchOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final products = await repository.getOrders();



    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

}