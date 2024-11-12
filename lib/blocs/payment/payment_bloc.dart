// payment_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/repositories/order/order_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';
import 'package:onlyveyou/models/order_item_model.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final OrderRepository orderRepository;
  List<OrderItemModel> _orderItems = [];
  int _totalAmount = 0; // 유지되는 totalAmount
  DeliveryInfoModel? _deliveryInfo;
  OrderType _orderType = OrderType.delivery; // 기본값 설정

  PaymentBloc({required this.orderRepository}) : super(PaymentInitial()) {
    on<FetchOrderItems>((event, emit) async {
      emit(PaymentLoading());
      try {
        _orderItems = await orderRepository.fetchOrderItems();
        _totalAmount = _orderItems.fold(
          0,
          (sum, item) => sum + (item.productPrice * item.quantity),
        );
        _orderType = await orderRepository.getOrderType();
        _deliveryInfo = await orderRepository.getDeliveryInfo();
        emit(PaymentLoaded(_orderItems, _totalAmount, _orderType,
            deliveryInfo: _deliveryInfo));
      } catch (e) {
        emit(const PaymentError('주문 상품을 불러오는데 실패했습니다.'));
      }
    });

    on<SelectDeliveryMessage>((event, emit) {
      if (_deliveryInfo != null) {
        _deliveryInfo =
            _deliveryInfo!.copyWith(deliveryRequest: event.deliveryMessage);
        emit(DeliveryInfoUpdated(
          _deliveryInfo!,
          _orderItems,
          _totalAmount,
          _orderType,
        ));
      } else {
        emit(PaymentMessageSelected(
          event.deliveryMessage,
          _orderItems,
          _totalAmount,
          _orderType,
          deliveryInfo: _deliveryInfo,
        ));
      }
    });

    on<UpdateDeliveryInfo>((event, emit) async {
      try {
        // 전달받은 필드들을 사용하여 DeliveryInfoModel 객체 생성
        _deliveryInfo = DeliveryInfoModel(
          deliveryName: event.deliveryName,
          address: event.address,
          detailAddress: event.detailAddress,
          recipientName: event.recipientName,
          recipientPhone: event.recipientPhone,
          deliveryRequest: _deliveryInfo?.deliveryRequest ??
              event.deliveryRequest, // 기존 요청사항 유지
        );
        emit(DeliveryInfoUpdated(_deliveryInfo!, _orderItems, _totalAmount,
            _orderType)); // 유지된 totalAmount 사용
      } catch (e) {
        emit(const PaymentError("배송지 정보를 업데이트하는 데 실패했습니다."));
      }
    });
  }

  DeliveryInfoModel? get deliveryInfo => _deliveryInfo;
}
