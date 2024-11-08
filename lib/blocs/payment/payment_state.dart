// payment_state.dart
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/order_item_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<OrderItemModel> orderItems;
  final int totalAmount;

  PaymentLoaded(this.orderItems, this.totalAmount);

  @override
  List<Object> get props => [orderItems, totalAmount];
}


class PaymentMessageSelected extends PaymentState {
  final String selectedMessage;
  final List<OrderItemModel> orderItems; // 추가된 부분

  const PaymentMessageSelected(this.selectedMessage, this.orderItems);

  @override
  List<Object> get props => [selectedMessage, orderItems];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}
