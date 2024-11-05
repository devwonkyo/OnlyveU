import 'package:equatable/equatable.dart';

abstract class OrderStatusEvent extends Equatable {
  const OrderStatusEvent();

  @override
  List<Object?> get props => [];
}

class SelectPurchaseType extends OrderStatusEvent {
  final String purchaseType;

  const SelectPurchaseType(this.purchaseType);

  @override
  List<Object?> get props => [purchaseType];
}

class SelectStatus extends OrderStatusEvent {
  final String status;

  const SelectStatus(this.status);

  @override
  List<Object?> get props => [status];
}
