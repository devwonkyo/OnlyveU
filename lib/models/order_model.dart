import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_item_model.dart';
import 'package:onlyveyou/models/store_model.dart';

/// 주문 유형 enum
enum OrderType {
  /// 픽업 주문
  pickup,

  /// 배송 주문
  delivery
}

/// 주문 상태 enum
enum OrderStatus {
  /// 주문 대기 (공통)
  pending,

  /// 주문 확인 (공통)
  confirmed,

  /// 주문 취소 (공통)
  canceled,

  /// 주문 완료 (공통)
  completed,

  /// 픽업 준비 완료 (픽업 주문)
  readyForPickup,

  /// 상품 준비중 (배송 주문)
  preparing,

  /// 배송중 (배송 주문)
  shipping,

  /// 배송 완료 (배송 주문)
  delivered,
}

class OrderModel {
  /// 주문 ID   자동으로 id생성하기 위해서 late
  late final String? id;

  /// 주문한 사용자 ID
  final String userId;

  /// 주문 상품 목록
  final List<OrderItemModel> items;

  /// 주문 상태
  final OrderStatus status;

  /// 주문 유형 (픽업/배송)
  final OrderType orderType;

  /// 총 주문 금액 - items의 가격 * 수량의 합으로 계산
  final int totalPrice;

  /// 주문 생성 시간
  final DateTime createdAt;

  /// 픽업 예정 시간 (픽업 주문인 경우)
  final DateTime? pickupTime;

  /// 픽업 매장 정보 (픽업 주문인 경우)
  final String? pickStore;

  final StoreModel? pickInfo;

  /// 배송 정보 (배송 주문인 경우)
  final DeliveryInfoModel? deliveryInfo;
  OrderModel({
    required this.userId,
    required this.items,
    required this.orderType,
    this.id,
    this.status = OrderStatus.pending,
    this.pickupTime,
    this.pickStore,
    this.deliveryInfo,
    this.pickInfo,
    DateTime? createdAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        totalPrice = items.fold(
            0,
            (sum, item) =>
                sum + (item.productPrice * item.quantity)); // items의 합으로 초기화

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? "",
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status.name,
      'orderType': orderType.name,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      if (orderType == OrderType.pickup) ...{
        'pickupTime': pickupTime?.toIso8601String(),
        'pickStore': pickStore,
        'pickInfo': pickInfo?.toMap(), // Added pickInfo
      },
      if (orderType == OrderType.delivery)
        'deliveryInfo': deliveryInfo?.toMap(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final orderType = OrderType.values.firstWhere(
          (e) => e.name == map['orderType'],
      orElse: () => OrderType.delivery, // 기본값 설정
    );

    final status = OrderStatus.values.firstWhere(
          (e) => e.name == map['status'],
      orElse: () => OrderStatus.pending, // 기본값 설정
    );

    return OrderModel(
      id: map['id'] as String?, // id를 map에서 직접 가져옴
      userId: map['userId'] as String,
      items: List<OrderItemModel>.from(
        (map['items'] as List).map((item) => OrderItemModel.fromMap(item)),
      ),
      status: status,
      orderType: orderType,
      pickupTime: map['pickupTime'] != null
          ? DateTime.parse(map['pickupTime'])
          : null,
      pickStore: map['pickStore'] as String?,
      pickInfo: map['pickInfo'] != null
          ? StoreModel.fromMap(map['pickInfo'])
          : null,
      deliveryInfo: map['deliveryInfo'] != null
          ? DeliveryInfoModel.fromMap(map['deliveryInfo'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
