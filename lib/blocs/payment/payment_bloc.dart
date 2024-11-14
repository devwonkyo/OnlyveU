// payment_bloc.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/store_model.dart';
import 'payment_event.dart';
import 'payment_state.dart';
import 'package:onlyveyou/models/order_item_model.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  List<OrderItemModel> _orderItems = [];
  int _totalAmount = 0; // 유지되는 totalAmount
  DeliveryInfoModel? _deliveryInfo;
  OrderType _orderType = OrderType.delivery; // 기본값 설정

  PaymentBloc() : super(const PaymentInitial()) {
    debugPrint("PaymentBloc has been created.");

    // InitializePayment 이벤트 핸들러
    on<InitializePayment>((event, emit) async {
      // 초기 상태로 PaymentLoading 상태를 emit
      emit(PaymentLoading(
        orderItems: const [],
        orderType: event.order.orderType,
        totalAmount: event.order.totalPrice,
        deliveryInfo: event.order.deliveryInfo,
      ));

      try {
        // 이벤트로부터 데이터 가져오기
        _orderItems = event.order.items;
        _totalAmount = event.order.totalPrice;
        _orderType = event.order.orderType;
        _deliveryInfo = event.order.deliveryInfo;

        if (_deliveryInfo != null) {
          print('Delivery Address: ${_deliveryInfo!.address}');
        } else {
          print('DeliveryInfo is null during InitializePayment.');
        }

        // PaymentLoaded 상태로 emit
        emit(PaymentLoaded(
          orderItems: _orderItems,
          totalAmount: _totalAmount,
          orderType: _orderType,
          deliveryInfo: _deliveryInfo,
        ));
      } catch (e) {
        emit(PaymentError(
          message: '초기화 중 오류가 발생했습니다.',
          orderItems: _orderItems,
          totalAmount: _totalAmount,
          orderType: _orderType,
          deliveryInfo: _deliveryInfo,
        ));
      }
    });

    // SelectDeliveryMessage 이벤트 핸들러
    on<SelectDeliveryMessage>((event, emit) {
      // deliveryInfo가 null이 아니면 deliveryRequest 업데이트
      if (_deliveryInfo != null) {
        _deliveryInfo =
            _deliveryInfo!.copyWith(deliveryRequest: event.deliveryMessage);
      } else {
        // deliveryInfo가 null일 경우, 기본값 설정 또는 예외 처리
        _deliveryInfo = DeliveryInfoModel(
          deliveryName: '', // 기본값 설정
          address: '',
          detailAddress: '',
          recipientName: '',
          recipientPhone: '',
          deliveryRequest: event.deliveryMessage,
        );
      }

      // 항상 PaymentLoaded 상태로 emit
      emit(PaymentLoaded(
        orderItems: _orderItems,
        totalAmount: _totalAmount,
        orderType: _orderType,
        deliveryInfo: _deliveryInfo,
      ));
    });

    // UpdateDeliveryInfo 이벤트 핸들러
    // payment_bloc.dart

    on<UpdateDeliveryInfo>((event, emit) async {
      try {
        final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

        // 사용자 인증 확인
        if (userId.isEmpty) {
          emit(PaymentError(
            message: '로그인이 필요합니다.',
            orderItems: _orderItems,
            totalAmount: _totalAmount,
            orderType: _orderType,
            deliveryInfo: _deliveryInfo,
          ));
          return;
        }

        // 이벤트로부터 전달받은 값들을 출력하여 확인
        print('Received UpdateDeliveryInfo event with:');
        print('delivderyName: ${event.deliveryName}');
        print('address: ${event.address}');
        print('detailAddress: ${event.detailAddress}');
        print('recipientName: ${event.recipientName}');
        print('recipientPhone: ${event.recipientPhone}');
        print('deliveryRequest: ${event.deliveryRequest}');

        // 전달받은 필드들을 사용하여 DeliveryInfoModel 객체 생성
        _deliveryInfo = DeliveryInfoModel(
          deliveryName: event.deliveryName,
          address: event.address,
          detailAddress: event.detailAddress,
          recipientName: event.recipientName,
          recipientPhone: event.recipientPhone,
          deliveryRequest:
              event.deliveryRequest ?? _deliveryInfo?.deliveryRequest,
        );

        print('Updated DeliveryInfdo: ${_deliveryInfo!.address}');

        // PaymentLoaded 상태로 emit하여 UI 업데이트
        emit(PaymentLoaded(
          orderItems: _orderItems,
          totalAmount: _totalAmount,
          orderType: _orderType,
          deliveryInfo: _deliveryInfo,
        ));
      } catch (e) {
        print('Exception in UpdateDeliveryInfo handler: $e');
        emit(PaymentError(
          message: "배송지 정보를 업데이트하는 데 실패했습니다.",
          orderItems: _orderItems,
          totalAmount: _totalAmount,
          orderType: _orderType,
          deliveryInfo: _deliveryInfo,
        ));
      }
    });

    // CheckOrderDetails 이벤트 핸들러
    on<CheckOrderDetails>((event, emit) {
      debugPrint("OrderModel details:");
      debugPrint("- User ID: ${FirebaseAuth.instance.currentUser?.uid ?? ''}");
      debugPrint("- Order Items: $_orderItems");
      debugPrint("- Total Amount: $_totalAmount");
      debugPrint("- Delivery Info: $_deliveryInfo");
      debugPrint("- Order Type: $_orderType");
    });

    // 기타 이벤트 핸들러...
  }

  DeliveryInfoModel? get deliveryInfo => _deliveryInfo;
}
