import 'package:flutter/material.dart';
import 'package:onlyveyou/models/cart_model.dart';
import 'package:onlyveyou/utils/format_price.dart';

class CartPriceSectionWidget extends StatelessWidget {
  final List<CartModel> items;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;

  const CartPriceSectionWidget({
    required this.items,
    required this.selectedItems,
    required this.itemQuantities,
  });

  // 총 상품 금액 계산 (할인 전)
  static int calculateTotalOriginalPrice({
    required List<CartModel> items,
    required Map<String, bool> selectedItems,
    required Map<String, int> itemQuantities,
  }) {
    return items.fold(0, (sum, item) {
      if (selectedItems[item.productId] == true) {
        final quantity = itemQuantities[item.productId] ?? 1;
        return sum + (item.productPrice * quantity);
      }
      return sum;
    });
  }

  // 할인 적용된 총 금액 계산
  static int calculateTotalDiscountedPrice({
    required List<CartModel> items,
    required Map<String, bool> selectedItems,
    required Map<String, int> itemQuantities,
  }) {
    return items.fold(0, (sum, item) {
      if (selectedItems[item.productId] == true) {
        final quantity = itemQuantities[item.productId] ?? 1;
        final discountedPrice =
            item.productPrice * (100 - item.discountPercent) / 100;
        return sum + (discountedPrice * quantity).round();
      }
      return sum;
    });
  }

  // 총 할인 금액 계산
  int calculateTotalDiscount() {
    final originalPrice = calculateTotalOriginalPrice(
      items: items,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );
    final discountedPrice = calculateTotalDiscountedPrice(
      items: items,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );
    return originalPrice - discountedPrice;
  }

  // 선택된 상품 개수 계산
  int _calculateSelectedItemCount() {
    return items.where((item) => selectedItems[item.productId] == true).length;
  }

  // 선택된 상품들의 총 수량 계산
  int _calculateTotalQuantity() {
    return items.fold(0, (sum, item) {
      if (selectedItems[item.productId] == true) {
        return sum + (itemQuantities[item.productId] ?? 1);
      }
      return sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final originalPrice = calculateTotalOriginalPrice(
      items: items,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );
    final discountedPrice = calculateTotalDiscountedPrice(
      items: items,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );
    final totalDiscount = calculateTotalDiscount();
    final selectedCount = _calculateSelectedItemCount();
    final totalQuantity = _calculateTotalQuantity();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // 선택된 상품 수량 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '선택된 상품 ($selectedCount)',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                '총 $totalQuantity개',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 상품 금액 정보 (할인 전)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '상품금액',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                '${formatPrice(originalPrice.toString())}원',
                style: TextStyle(
                  decoration:
                      totalDiscount > 0 ? TextDecoration.lineThrough : null,
                  color: totalDiscount > 0 ? Colors.grey[600] : Colors.black,
                ),
              ),
            ],
          ),

          // 할인 금액이 있는 경우에만 표시
          if (totalDiscount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '할인금액',
                  style: TextStyle(color: Colors.red[700]),
                ),
                Text(
                  '-${formatPrice(totalDiscount.toString())}원',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // 배송비 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '배송비',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Text(
                '0원',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),

          // 결제 예상 금액 (할인 적용된 최종 금액)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '결제 예상 금액',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${formatPrice(discountedPrice.toString())}원',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          if (selectedCount > 0) ...[
            const SizedBox(height: 16),
            // 적립 예상 포인트 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '적립 예상 포인트',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${formatPrice((discountedPrice * 0.01).round().toString())}P',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
