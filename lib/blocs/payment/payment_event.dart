import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

/// 배송 메시지 선택 이벤트
class SelectDeliveryMessage extends PaymentEvent {
  final String message;

  const SelectDeliveryMessage(this.message);

  @override
  List<Object> get props => [message];
}

/// 주문 상품을 가져오는 이벤트 추가
class FetchOrderItems extends PaymentEvent {
  const FetchOrderItems();

  @override
  List<Object> get props => [];
}
