// payment_event.dart
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_model.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class SelectDeliveryMessage extends PaymentEvent {
  final String deliveryMessage;

  const SelectDeliveryMessage(this.deliveryMessage);

  @override
  List<Object> get props => [deliveryMessage];
}

class FetchOrderItems extends PaymentEvent {
  const FetchOrderItems();

  @override
  List<Object> get props => [];
}

// UpdateDeliveryInfo 이벤트에서 각 필드 값을 개별적으로 전달
class UpdateDeliveryInfo extends PaymentEvent {
  final String deliveryName;
  final String address;
  final String detailAddress;
  final String recipientName;
  final String recipientPhone;
  final String? deliveryRequest;

  const UpdateDeliveryInfo({
    required this.deliveryName,
    required this.address,
    required this.detailAddress,
    required this.recipientName,
    required this.recipientPhone,
    this.deliveryRequest,
  });

  @override
  List<Object> get props => [
        deliveryName,
        address,
        detailAddress,
        recipientName,
        recipientPhone,
        deliveryRequest!
      ];
}

class UpdateDeliveryRequest extends PaymentEvent {
  final String deliveryRequest;

  const UpdateDeliveryRequest(this.deliveryRequest);

  @override
  List<Object> get props => [deliveryRequest];
}

class CheckOrderDetails extends PaymentEvent {
  const CheckOrderDetails();

  @override
  List<Object> get props => [];
}

// payment_event.dart
// payment_event.dart
class SubmitOrder extends PaymentEvent {
  final OrderModel order;

  const SubmitOrder(this.order);

  @override
  List<Object> get props => [order];
}


class InitializePayment extends PaymentEvent {
  final OrderModel order;

  const InitializePayment(this.order);

  @override
  List<Object> get props => [order];
}

class TestEvent extends PaymentEvent {
  const TestEvent();

  @override
  List<Object> get props => [];
}
