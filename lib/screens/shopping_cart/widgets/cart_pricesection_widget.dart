import 'package:flutter/material.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';

import '../../../models/product_model.dart';
//탭 헤더 페이지에 묶여있어서 쇼핑카트 스크린에 안나와도 된다
//가격계산

/// CartPriceSectionWidget: 장바구니에서 상품의 총 금액, 할인 금액, 최종 결제 금액을
/// 계산하고 표시하는 위젯
class CartPriceSectionWidget extends StatelessWidget {
  final List<ProductModel> items; // 장바구니에 담긴 상품 목록
  final Map<String, bool> selectedItems; // 각 상품의 선택 상태 (선택 여부)
  final Map<String, int> itemQuantities; // 각 상품의 수량 정보

  const CartPriceSectionWidget({
    required this.items,
    required this.selectedItems,
    required this.itemQuantities,
  });

  // calculateTotalPrice: 선택된 상품의 총 금액을 계산
  static int calculateTotalPrice({
    required List<ProductModel> items,
    required Map<String, bool> selectedItems,
    required Map<String, int> itemQuantities,
  }) {
    return items.fold(0, (sum, item) {
      if (selectedItems[item.productId] == true) {
        // 상품이 선택된 경우
        int quantity =
            itemQuantities[item.productId] ?? 1; // 선택된 상품의 수량 (기본값은 1)
        return sum +
            (int.parse(item.price) * quantity); // 총 금액에 상품의 가격과 수량을 곱해 더함
      }
      return sum; // 선택되지 않은 상품은 금액에 포함하지 않음
    });
  }

  // calculateTotalDiscount: 선택된 상품의 총 할인 금액을 계산
  static int calculateTotalDiscount({
    required List<ProductModel> items,
    required Map<String, bool> selectedItems,
    required Map<String, int> itemQuantities,
  }) {
    return items.fold(0, (sum, item) {
      if (selectedItems[item.productId] == true) {
        // 상품이 선택된 경우
        int quantity =
            itemQuantities[item.productId] ?? 1; // 선택된 상품의 수량 (기본값은 1)
        int originalPrice = int.parse(item.price); // 원래 가격
        int discountedPrice = item.discountedPrice; // 할인된 가격
        return sum +
            ((originalPrice - discountedPrice) * quantity); // 할인 금액을 수량만큼 곱해 더함
      }
      return sum; // 선택되지 않은 상품은 할인 금액에 포함하지 않음
    });
  }

  // formatPrice: 가격을 천 단위마다 콤마를 추가해 포맷팅 -위젯 끌어옴
  String formatPrice(String price) {
    return price.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    // 총 상품 금액을 계산
    final totalPrice = calculateTotalPrice(
      items: items,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );

    // 총 할인 금액을 계산
    final totalDiscount = calculateTotalDiscount(
      items: items,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );

    // 최종 결제 금액 계산 (총 상품 금액 - 총 할인 금액)
    final finalPrice = totalPrice - totalDiscount;

    // UI 구성
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 총 상품 금액 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우로 배치
            children: [
              Text('총 상품금액'),
              Text('${formatPrice(totalPrice.toString())}원',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),

          // 총 할인 금액 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 할인금액'),
              Text('${formatPrice(totalDiscount.toString())}원',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),

          // 배송비 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 배송비'),
              Text('0원',
                  style: TextStyle(
                      fontWeight: FontWeight.bold)), // 배송비는 여기서 0원으로 고정
            ],
          ),
          Divider(height: 32),

          // 최종 결제 금액 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최종 결제금액'),
              Text('${formatPrice(finalPrice.toString())}원',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
