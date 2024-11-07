import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {
  final String selectedMessage = '배송 메시지를 선택해주세요.';
}

class PaymentMessageSelected extends PaymentState {
  final String selectedMessage;

  const PaymentMessageSelected(this.selectedMessage);

  @override
  List<Object> get props => [selectedMessage];
}
