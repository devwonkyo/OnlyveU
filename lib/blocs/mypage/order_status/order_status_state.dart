import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/order_model.dart';

abstract class OrderStatusState extends Equatable {
  const OrderStatusState();

  @override
  List<Object?> get props => [];
}

class OrderStatusInitial extends OrderStatusState {
  final String selectedPurchaseType = '온라인몰 구매';
  final List<String> statusOptions = [
    '전체 상태',
    '주문접수',
    '결제완료',
    '배송준비중',
    '배송중',
    '배송완료'
  ];
  final String selectedStatus = '전체 상태';

  OrderStatusInitial();
}

class PurchaseTypeSelected extends OrderStatusState {
  final String selectedPurchaseType;
  final List<String> statusOptions;
  final String selectedStatus;

  const PurchaseTypeSelected(
      this.selectedPurchaseType, this.statusOptions, this.selectedStatus);

  @override
  List<Object?> get props =>
      [selectedPurchaseType, statusOptions, selectedStatus];
}

class StatusSelected extends OrderStatusState {
  final String selectedPurchaseType;
  final List<String> statusOptions;
  final String selectedStatus;

  const StatusSelected(
      this.selectedPurchaseType, this.statusOptions, this.selectedStatus);

  @override
  List<Object?> get props =>
      [selectedPurchaseType, statusOptions, selectedStatus];
}

class OrderFetch extends OrderStatusState {
    final List<OrderModel> orders;
  const OrderFetch(this.orders);
  @override
  List<Object?> get props => [];
}
