import 'package:onlyveyou/models/order_item_model.dart';
import 'package:onlyveyou/models/order_model.dart';

class AvailableOrderModel {
  final String productId;
  final String orderId;
  final String orderUserId;
  final OrderItemModel orderItem;
  final DateTime purchaseDate;
  final OrderType orderType;

  AvailableOrderModel({
    required this.productId,
    required this.orderId,
    required this.orderUserId,
    required this.orderItem,
    required this.purchaseDate,
    required this.orderType,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'orderId': orderId,
      'orderUserId': orderUserId,
      'orderItem': orderItem.toMap(),
      'purchaseDate': purchaseDate.toIso8601String(),
      'orderType': orderType.name,
    };
  }

  factory AvailableOrderModel.fromMap(Map<String, dynamic> map) {
    return AvailableOrderModel(
      productId: map['productId'],
      orderId: map['orderId'],
      orderUserId: map['orderUserId'],
      orderItem: OrderItemModel.fromMap(map['orderItem']),
      purchaseDate: DateTime.parse(map['purchaseDate']),
      orderType: OrderType.values.firstWhere(
            (e) => e.name == map['orderType'],
        orElse: () => OrderType.delivery,  // 기본값 설정
      ),
    );
  }

  AvailableOrderModel copyWith({
    String? productId,
    String? orderId,
    String? orderUserId,
    OrderItemModel? orderItem,
    DateTime? purchaseDate,
    OrderType? orderType,
  }) {
    return AvailableOrderModel(
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      orderUserId: orderUserId ?? this.orderUserId,
      orderItem: orderItem ?? this.orderItem,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      orderType: orderType ?? this.orderType,
    );
  }
}