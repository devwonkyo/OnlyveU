// payment_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/repositories/order/order_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';
import 'package:onlyveyou/models/order_item_model.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final OrderRepository orderRepository;
  List<OrderItemModel> _orderItems = [];
  DeliveryInfoModel? _deliveryInfo; // 새로운 배송지 정보 저장을 위한 필드

  final int _totalAmount = 0; // 유지되는 totalAmount
  PaymentBloc({required this.orderRepository}) : super(PaymentInitial()) {
    on<FetchOrderItems>((event, emit) async {
      emit(PaymentLoading());
      try {
        _orderItems = await orderRepository.fetchOrderItems();
        int totalAmount = _orderItems.fold(
          0,
          (sum, item) => sum + (item.productPrice * item.quantity),
        );
        emit(PaymentLoaded(_orderItems, totalAmount));
      } catch (e) {
        emit(const PaymentError('주문 상품을 불러오는데 실패했습니다.'));
      }
    });

    on<SelectDeliveryMessage>((event, emit) {
      if (_deliveryInfo != null) {
        // 기존 deliveryInfo에 요청사항 업데이트
        _deliveryInfo =
            _deliveryInfo!.copyWith(deliveryRequest: event.deliveryMessage);
        emit(DeliveryInfoUpdated(
            _deliveryInfo!, _orderItems, _totalAmount)); // 유지된 totalAmount 사용
      }
      emit(PaymentMessageSelected(event.deliveryMessage, _orderItems,
          _totalAmount)); // 유지된 totalAmount 사용

      print('배송지 정보 입력 완료:');
      print('배송지 명: ${_deliveryInfo!.deliveryName}');
      print('주소: ${_deliveryInfo!.address}');
      print('상세 주소: ${_deliveryInfo!.detailAddress}');
      print('받는 이: ${_deliveryInfo!.recipientName}');
      print('전화 번호: ${_deliveryInfo!.recipientPhone}');
      print('배송 요청사항: ${_deliveryInfo!.deliveryRequest}');
    });

    // 새로운 배송지 정보를 업데이트하는 이벤트 처리
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
        print('배송지 정보 입력 완료:');
        print('배송지 명: ${_deliveryInfo!.deliveryName}');
        print('주소: ${_deliveryInfo!.address}');
        print('상세 주소: ${_deliveryInfo!.detailAddress}');
        print('받는 이: ${_deliveryInfo!.recipientName}');
        print('전화 번호: ${_deliveryInfo!.recipientPhone}');
        print('배송 요청사항: ${_deliveryInfo!.deliveryRequest}');
        emit(DeliveryInfoUpdated(_deliveryInfo!, _orderItems, _totalAmount));

        // print문으로 현재 _deliveryInfo의 값을 출력
      } catch (e) {
        emit(const PaymentError("배송지 정보를 업데이트하는 데 실패했습니다."));
      }
    });

    // 배송 요청사항 업데이트
    on<UpdateDeliveryRequest>((event, emit) {
      if (_deliveryInfo != null) {
        // 기존 배송지 정보에 요청사항만 추가 업데이트
        _deliveryInfo = _deliveryInfo!.copyWith(
          deliveryRequest: event.deliveryRequest,
        );
        emit(DeliveryInfoUpdated(_deliveryInfo!, _orderItems, _totalAmount));
      }
    });
  }

  DeliveryInfoModel? get deliveryInfo => _deliveryInfo;
}
