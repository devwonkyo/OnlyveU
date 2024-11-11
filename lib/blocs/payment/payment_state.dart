import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_item_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  List<OrderItemModel> get orderItems => [];
  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  @override
  final List<OrderItemModel> orderItems;
  final int totalAmount;

  const PaymentLoaded(this.orderItems, this.totalAmount);

  @override
  List<Object> get props => [orderItems, totalAmount];
}

class PaymentMessageSelected extends PaymentState {
  final String selectedMessage;
  @override
  final List<OrderItemModel> orderItems;
  final int totalAmount; // totalAmount를 추가
  const PaymentMessageSelected(
      this.selectedMessage, this.orderItems, this.totalAmount);

  @override
  List<Object> get props => [selectedMessage, orderItems, totalAmount];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}

class DeliveryInfoUpdated extends PaymentState {
  final DeliveryInfoModel deliveryInfo;
  @override
  final List<OrderItemModel> orderItems;
  final int totalAmount; // totalAmount 필드 추가

  const DeliveryInfoUpdated(
      this.deliveryInfo, this.orderItems, this.totalAmount);

  @override
  List<Object> get props => [deliveryInfo, orderItems, totalAmount];
}
