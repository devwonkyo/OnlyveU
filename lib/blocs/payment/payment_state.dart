import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_item_model.dart';
import 'package:onlyveyou/models/order_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  List<OrderItemModel> get orderItems => [];
  OrderType get orderType => OrderType.delivery; // 기본값 설정
   DeliveryInfoModel? get deliveryInfo => null; // deliveryInfo를 추상 getter로 추가
  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  @override
  final List<OrderItemModel> orderItems;
  final int totalAmount;
  @override
  final OrderType orderType;
  @override
  final DeliveryInfoModel? deliveryInfo;

  const PaymentLoaded(this.orderItems, this.totalAmount, this.orderType, {this.deliveryInfo});

  @override
  List<Object> get props => [orderItems, totalAmount, orderType, deliveryInfo!];
}
// 다른 상태들도 orderType과 필요한 데이터를 포함하도록 수정
class PaymentMessageSelected extends PaymentState {
  final String selectedMessage;
  @override
  final List<OrderItemModel> orderItems;
  final int totalAmount;
  @override
  final OrderType orderType;
  final DeliveryInfoModel? deliveryInfo;

  const PaymentMessageSelected(
    this.selectedMessage,
    this.orderItems,
    this.totalAmount,
    this.orderType, {
    this.deliveryInfo,
  });

  @override
  List<Object> get props => [selectedMessage, orderItems, totalAmount, orderType, deliveryInfo!];
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
  final int totalAmount;
  @override
  final OrderType orderType;

  const DeliveryInfoUpdated(
    this.deliveryInfo,
    this.orderItems,
    this.totalAmount,
    this.orderType,
  );

  @override
  List<Object> get props => [deliveryInfo, orderItems, totalAmount, orderType];
}