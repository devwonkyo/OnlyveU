import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_item_model.dart';

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
  /// 주문 ID
  final String id;

  /// 주문한 사용자 ID
  final String userId;

  /// 주문 상품 목록
  final List<OrderItemModel> items;

  /// 주문 상태
  final OrderStatus status;

  /// 주문 유형 (픽업/배송)
  final OrderType orderType;

  /// 총 주문 금액
  final int totalPrice;

  /// 주문 생성 시간
  final DateTime createdAt;

  /// 픽업 예정 시간 (픽업 주문인 경우)
  final DateTime? pickupTime;

  /// 배송 정보 (배송 주문인 경우)
  final DeliveryInfoModel? deliveryInfo;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.orderType,
    this.status = OrderStatus.pending,
    required this.totalPrice,
    this.pickupTime,
    this.deliveryInfo,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status.name,
      'orderType': orderType.name,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      if (orderType == OrderType.pickup)
        'pickupTime': pickupTime?.toIso8601String(),
      if (orderType == OrderType.delivery)
        'deliveryInfo': deliveryInfo?.toMap(),
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final orderType = OrderType.values.firstWhere(
            (e) => e.name == map['orderType']
    );

    return OrderModel(
      id: id,
      userId: map['userId'],
      items: List<OrderItemModel>.from(
          map['items'].map((item) => OrderItemModel.fromMap(item))
      ),
      status: OrderStatus.values.firstWhere(
              (e) => e.name == map['status']
      ),
      orderType: orderType,
      totalPrice: map['totalPrice'],
      pickupTime: map['pickupTime'] != null
          ? DateTime.parse(map['pickupTime'])
          : null,
      deliveryInfo: map['deliveryInfo'] != null
          ? DeliveryInfoModel.fromMap(map['deliveryInfo'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}