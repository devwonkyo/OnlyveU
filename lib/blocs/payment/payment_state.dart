// payment_state.dart

import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_item_model.dart';
import 'package:onlyveyou/models/order_model.dart';

abstract class PaymentState extends Equatable {
  final List<OrderItemModel> orderItems;
  final OrderType orderType;
  final int totalAmount;
  final DeliveryInfoModel? deliveryInfo;

  const PaymentState({
    required this.orderItems,
    required this.orderType,
    required this.totalAmount,
    this.deliveryInfo,
  });

  @override
  List<Object?> get props => [orderItems, orderType, totalAmount, deliveryInfo];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial()
      : super(
          orderItems: const [],
          orderType: OrderType.delivery, // 기본값 설정
          totalAmount: 0,
          deliveryInfo: null,
        );
}

class PaymentLoading extends PaymentState {
  const PaymentLoading({
    required super.orderItems,
    required super.orderType,
    required super.totalAmount,
    super.deliveryInfo,
  });
}

class PaymentLoaded extends PaymentState {
  const PaymentLoaded({
    required super.orderItems,
    required super.totalAmount,
    required super.orderType,
    super.deliveryInfo,
  });

  @override
  String toString() {
    return 'PaymentLoaded(orderItems: $orderItems, orderType: $orderType, totalAmount: $totalAmount, deliveryInfo: $deliveryInfo)';
  }
}

class PaymentMessageSelected extends PaymentState {
  final String selectedMessage;

  const PaymentMessageSelected({
    required this.selectedMessage,
    required super.orderItems,
    required super.totalAmount,
    required super.orderType,
    super.deliveryInfo,
  });

  @override
  List<Object?> get props => super.props + [selectedMessage];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError({
    required this.message,
    required super.orderItems,
    required super.totalAmount,
    required super.orderType,
    super.deliveryInfo,
  });

  @override
  List<Object?> get props => super.props + [message];
}
