// payment_bloc.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/store_model.dart';
import 'package:onlyveyou/repositories/order/order_repository.dart';
import 'package:uuid/uuid.dart';
import 'payment_event.dart';
import 'payment_state.dart';
import 'package:onlyveyou/models/order_item_model.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  List<OrderItemModel> _orderItems = [];
  int _totalAmount = 0; // 유지되는 totalAmount
  DeliveryInfoModel? _deliveryInfo;
  OrderType _orderType = OrderType.delivery; // 기본값 설정
  final OrderRepository orderRepository;

  PaymentBloc({required this.orderRepository}) : super(PaymentInitial()) {
    debugPrint("PaymentBloc has been created.");
    // 먼저 _initializePayment 함수를 선언

    Future<void> initializePayment(
      InitializePayment event,
      Emitter<PaymentState> emit,
    ) async {
      print("initializePayment triggered"); // 여기에 로그 추가
      emit(PaymentLoading());

      try {
        // _orderItems가 비어 있는 경우만 초기화
        if (_orderItems.isEmpty) {
          _orderItems = event.order.items;
          _totalAmount = event.order.totalPrice;
          _orderType = event.order.orderType;
          _deliveryInfo = event.order.deliveryInfo;
        }

        emit(PaymentLoaded(
          _orderItems,
          _totalAmount,
          _orderType,
          _deliveryInfo,
        ));
      } catch (e) {
        emit(const PaymentError('초기화 중 오류가 발생했습니다.'));
      }
    }

    // on 이벤트 핸들러들 설정
    on<InitializePayment>(initializePayment);

    on<SelectDeliveryMessage>((event, emit) {
      if (_deliveryInfo != null) {
        _deliveryInfo =
            _deliveryInfo!.copyWith(deliveryRequest: event.deliveryMessage);
      } else {
        // 기본 값을 설정하거나, 필요한 필드를 채워줌
        _deliveryInfo = DeliveryInfoModel(
          deliveryName: '', // 적절한 기본값 설정
          address: '',
          detailAddress: '',
          recipientName: '',
          recipientPhone: '',
          deliveryRequest: event.deliveryMessage,
        );
      }
      emit(DeliveryInfoUpdated(
        _deliveryInfo!,
        _orderItems,
        _totalAmount,
        _orderType,
      ));
    });

    on<UpdateDeliveryInfo>((event, emit) async {
      try {
        final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

        if (userId.isEmpty) {
          emit(const PaymentError('로그인이 필요합니다.'));
          return;
        }

        // 전달받은 필드들을 사용하여 DeliveryInfoModel 객체 생성
        _deliveryInfo = DeliveryInfoModel(
          deliveryName: event.deliveryName,
          address: event.address,
          detailAddress: event.detailAddress,
          recipientName: event.recipientName,
          recipientPhone: event.recipientPhone,
          deliveryRequest:
              _deliveryInfo?.deliveryRequest ?? event.deliveryRequest,
        );

        print("Updated delivery info: ${_deliveryInfo!.toMap()}");

        // PaymentLoaded 상태로 emit하지 않고 바로 DeliveryInfoUpdated 상태로 유지
        emit(DeliveryInfoUpdated(
          _deliveryInfo!,
          _orderItems,
          _totalAmount,
          _orderType,
        ));
      } catch (e) {
        emit(const PaymentError("배송지 정보를 업데이트하는 데 실패했습니다."));
      }
    });

    //주문하기 메서드
    on<SubmitOrder>(
      (SubmitOrder event, Emitter<PaymentState> emit) async {
        try {
          emit(PaymentLoading());

          // 각 OrderItemModel에 랜덤 orderItemId 생성
          final updatedItems = event.order.items.map((item) {
            final randomOrderItemId = const Uuid().v4(); // 랜덤 UUID 생성
            return item.copyWith(orderItemId: randomOrderItemId);
          }).toList();

          // 업데이트된 items로 새로운 OrderModel 생성
          final updatedOrder = event.order.copyWith(items: updatedItems);

          // Firestore에 업데이트된 Order 저장
          await orderRepository.saveOrder(updatedOrder);

          emit(PaymentSuccess());
        } catch (e) {
          emit(const PaymentError('주문 제출 중 오류가 발생했습니다.'));
        }
      },
    );

    on<CheckOrderDetails>((event, emit) {
      debugPrint("OrderModel details:");
      debugPrint("- User ID: ${FirebaseAuth.instance.currentUser?.uid ?? ''}");
      debugPrint("- Order Items: $_orderItems");
      debugPrint("- Total Amount: $_totalAmount");
      debugPrint("- Delivery Info: $_deliveryInfo");
      debugPrint("- Order Type: $_orderType");
    });
  }

  DeliveryInfoModel? get deliveryInfo => _deliveryInfo;
}
