// // payment_bloc.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:onlyveyou/models/delivery_info_model.dart';
// import 'package:onlyveyou/models/order_model.dart';
// import 'package:onlyveyou/models/store_model.dart';
// import 'package:onlyveyou/repositories/order/order_repository.dart';
// import 'payment_event.dart';
// import 'payment_state.dart';
// import 'package:onlyveyou/models/order_item_model.dart';

// class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
//   List<OrderItemModel> _orderItems = [];
//   int _totalAmount = 0; // 유지되는 totalAmount
//   DeliveryInfoModel? _deliveryInfo;
//   OrderType _orderType = OrderType.delivery; // 기본값 설정

//   PaymentBloc() : super(PaymentInitial()) {
//     debugPrint("PaymentBloc has been created.");
//     // 먼저 _initializePayment 함수를 선언

//     Future<void> initializePayment(
//       InitializePayment event,
//       Emitter<PaymentState> emit,
//     ) async {
//       emit(PaymentLoading());

//       try {
//         _orderItems = event.order.items;
//         _totalAmount = event.order.totalPrice;
//         _orderType = event.order.orderType;
//         _deliveryInfo = event.order.deliveryInfo;

//         emit(PaymentLoaded(
//           _orderItems,
//           _totalAmount,
//           _orderType,
//           deliveryInfo: _deliveryInfo,
//         ));
//       } catch (e) {
//         emit(const PaymentError('초기화 중 오류가 발생했습니다.'));
//       }
//     }
//       // on 이벤트 핸들러들 설정
//     on<InitializePayment>(initializePayment);

//     on<SelectDeliveryMessage>((event, emit) {
//       if (_deliveryInfo != null) {
//         _deliveryInfo =
//             _deliveryInfo!.copyWith(deliveryRequest: event.deliveryMessage);
//         emit(DeliveryInfoUpdated(
//           _deliveryInfo!,
//           _orderItems,
//           _totalAmount,
//           _orderType,
//         ));
//       } else {
//         emit(PaymentMessageSelected(
//           event.deliveryMessage,
//           _orderItems,
//           _totalAmount,
//           _orderType,
//           deliveryInfo: _deliveryInfo,
//         ));
//       }
//     });

//     on<UpdateDeliveryInfo>((event, emit) async {
//       try {
//         final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

//         // 사용자 인증 확인
//         if (userId.isEmpty) {
//           emit(const PaymentError('로그인이 필요합니다.'));
//           return;
//         }

//         // 전달받은 필드들을 사용하여 DeliveryInfoModel 객체 생성
//         _deliveryInfo = DeliveryInfoModel(
//           deliveryName: event.deliveryName,
//           address: event.address,
//           detailAddress: event.detailAddress,
//           recipientName: event.recipientName,
//           recipientPhone: event.recipientPhone,
//           deliveryRequest: _deliveryInfo?.deliveryRequest ??
//               event.deliveryRequest, // 기존 요청사항 유지
//         );

//         emit(DeliveryInfoUpdated(_deliveryInfo!, _orderItems, _totalAmount,
//             _orderType)); // 유지된 totalAmount 사용
//       } catch (e) {
//         emit(const PaymentError("배송지 정보를 업데이트하는 데 실패했습니다."));
//       }
//     });

//     on<CheckOrderDetails>((event, emit) {
//       debugPrint("OrderModel details:");
//       debugPrint("- User ID: ${FirebaseAuth.instance.currentUser?.uid ?? ''}");
//       debugPrint("- Order Items: $_orderItems");
//       debugPrint("- Total Amount: $_totalAmount");
//       debugPrint("- Delivery Info: $_deliveryInfo");
//       debugPrint("- Order Type: $_orderType");
//     });

// //  on<SubmitOrder>((event, emit) async {
// //   try {
// //     // 사용자 ID 가져오기 (Firebase Authentication 사용 시)
// //     final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

// //     // 사용자 인증 확인
// //     if (userId.isEmpty) {
// //       emit(const PaymentError('로그인이 필요합니다.'));
// //       return;
// //     }

// //     // 주문 데이터 수집
// //     final List<OrderItemModel> items = _orderItems; // Bloc의 상태에서 가져오기
// //     final OrderType orderType = _orderType; // Bloc의 상태에서 가져오기
// //     final DeliveryInfoModel? deliveryInfo = _deliveryInfo; // Bloc의 상태에서 가져오기
// //     final int totalPrice = _totalAmount; // Bloc의 상태에서 가져오기

// //     // 주문 유형에 따른 추가 데이터 처리
// //     DateTime? pickupTime;
// //     String? pickStore;
// //     StoreModel? pickInfo;

// //     if (orderType == OrderType.pickup) {
// //       // 픽업 주문인 경우 필요한 데이터 설정
// //       pickupTime = _pickupTime; // Bloc에서 관리되는 픽업 시간
// //       pickStore = _pickStore; // Bloc에서 관리되는 픽업 매장 ID 또는 이름
// //       pickInfo = _pickInfo; // Bloc에서 관리되는 픽업 매장 정보
// //     }

// //     // 새로운 OrderModel 생성
// //     final OrderModel newOrder = OrderModel(
// //       id: null, // 새로운 주문이므로 id는 null로 설정
// //       userId: userId,
// //       items: items,
// //       orderType: orderType,
// //       deliveryInfo: deliveryInfo,
// //       pickupTime: pickupTime,
// //       pickStore: pickStore,
// //       pickInfo: pickInfo,
// //       // 기타 필요한 필드들 추가
// //     );

// //     // 주문을 Firestore에 저장
// //     final String orderId = await orderRepository.saveOrder(newOrder);

// //     // 주문 성공 상태 방출 또는 추가 처리
// //     emit(const PaymentSuccess());
// //   } catch (e) {
// //     emit(PaymentError('주문 제출에 실패했습니다: $e'));
// //   }
// // });
//   }

//   DeliveryInfoModel? get deliveryInfo => _deliveryInfo;
// }

// payment_bloc.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/store_model.dart';
import 'package:onlyveyou/repositories/order/order_repository.dart';
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
      (SubmitOrder event, Emitter<PaymentState> emitt) async {
        try {
          emit(PaymentLoading());
          // Firestore에 주문 데이터 저장
          await orderRepository.saveOrder(event.order);

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
