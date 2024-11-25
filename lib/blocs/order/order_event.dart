import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/order_model.dart';

abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// 주문 목록을 가져오는 이벤트
class FetchOrdersEvent extends OrderEvent {}

// 특정 주문의 상세 정보를 가져오는 이벤트
class FetchOrderDetailEvent extends OrderEvent {
  final String orderId;

  FetchOrderDetailEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

// 주문을 생성하는 이벤트
class CreateOrderEvent extends OrderEvent {
  final OrderModel order;

  CreateOrderEvent(this.order);

  @override
  List<Object?> get props => [order];
}

// 주문을 업데이트하는 이벤트
class UpdateOrderEvent extends OrderEvent {
  final OrderModel order;

  UpdateOrderEvent(this.order);

  @override
  List<Object?> get props => [order];
}

// 주문을 삭제하는 이벤트
class DeleteOrderEvent extends OrderEvent {
  final String orderId;

  DeleteOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

// 주문 목록을 가져오는 이벤트
class FetchAvailableReviewOrdersEvent extends OrderEvent {}
