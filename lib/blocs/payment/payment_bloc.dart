// payment_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/repositories/order/order_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';
import 'package:onlyveyou/models/order_item_model.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final OrderRepository orderRepository;
  List<OrderItemModel> _orderItems = [];

  PaymentBloc({required this.orderRepository}) : super(PaymentInitial()) {
    on<FetchOrderItems>((event, emit) async {
      emit(PaymentLoading());
      try {
        _orderItems = await orderRepository.fetchOrderItems();
        int totalAmount = _orderItems.fold(
          0,
          (sum, item) => sum + (item.productPrice * item.quantity),
        );
        emit(PaymentLoaded(_orderItems, totalAmount));
      } catch (e) {
        emit(PaymentError('주문 상품을 불러오는데 실패했습니다.'));
      }
    });

    on<SelectDeliveryMessage>((event, emit) {
      emit(PaymentMessageSelected(event.message, _orderItems));
    });
  }
}
