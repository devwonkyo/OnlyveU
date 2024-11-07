import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class SelectDeliveryMessage extends PaymentEvent {
  final String message;

  const SelectDeliveryMessage(this.message);

  @override
  List<Object> get props => [message];
}
