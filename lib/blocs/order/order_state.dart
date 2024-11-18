import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/available_review_model.dart';
import 'package:onlyveyou/models/order_model.dart';

abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

// 초기 상태
class OrderInitial extends OrderState {}

// 로딩 상태
class OrderLoading extends OrderState {}

// 주문 목록이 로드된 상태
class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;

  OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

// 주문 상세 정보가 로드된 상태
class OrderDetailLoaded extends OrderState {
  final OrderModel order;

  OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

// 에러 상태
class OrderError extends OrderState {
  final String message;

  OrderError(this.message);

  @override
  List<Object?> get props => [message];
}


// 주문 목록이 로드된 상태
class AvailableReviewOrderLoaded extends OrderState {
  final List<AvailableOrderModel> orders;

  AvailableReviewOrderLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}
