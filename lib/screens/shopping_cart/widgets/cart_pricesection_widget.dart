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

  // 총 상품 금액 계산
  static int calculateTotalPrice({
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
    final totalPrice = calculateTotalPrice(
      items: items,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );

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

          // 상품 금액 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '상품금액',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                '${formatPrice(totalPrice.toString())}원',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
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

          // 결제 예상 금액
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
                '${formatPrice(totalPrice.toString())}원',
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
                    '${formatPrice((totalPrice * 0.01).round().toString())}P',
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
