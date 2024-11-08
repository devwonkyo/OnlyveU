import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/repositories/order/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';
import 'package:onlyveyou/models/order_model.dart';


class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(OrderInitial()) {
    // 주문 목록 가져오기
    on<FetchOrdersEvent>((event, emit) async {
      emit(OrderLoading());
      try {
        final orders = await orderRepository.fetchOrders();
        emit(OrdersLoaded(orders));
      } catch (e) {
        emit(OrderError('주문 목록을 불러오는데 실패했습니다.'));
      }
    });

    // 주문 상세 정보 가져오기
    on<FetchOrderDetailEvent>((event, emit) async {
      emit(OrderLoading());
      try {
        final order = await orderRepository.fetchOrderDetail(event.orderId);
        emit(OrderDetailLoaded(order));
      } catch (e) {
        emit(OrderError('주문 정보를 불러오는데 실패했습니다.'));
      }
    });

    // 주문 생성
    on<CreateOrderEvent>((event, emit) async {
      emit(OrderLoading());
      try {
        await orderRepository.createOrder(event.order);
        emit(OrderInitial());
      } catch (e) {
        emit(OrderError('주문 생성에 실패했습니다.'));
      }
    });

    // 주문 업데이트
    on<UpdateOrderEvent>((event, emit) async {
      emit(OrderLoading());
      try {
        await orderRepository.updateOrder(event.order);
        emit(OrderInitial());
      } catch (e) {
        emit(OrderError('주문 업데이트에 실패했습니다.'));
      }
    });

    // 주문 삭제
    on<DeleteOrderEvent>((event, emit) async {
      emit(OrderLoading());
      try {
        await orderRepository.deleteOrder(event.orderId);
        emit(OrderInitial());
      } catch (e) {
        emit(OrderError('주문 삭제에 실패했습니다.'));
      }
    });
  }
}
