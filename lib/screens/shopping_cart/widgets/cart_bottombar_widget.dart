import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/models/cart_model.dart';
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_pricesection_widget.dart';
import 'package:onlyveyou/utils/format_price.dart';

class CartBottomBarWidget extends StatelessWidget {
  final List<CartModel> currentItems;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;

  const CartBottomBarWidget({
    super.key,
    required this.currentItems,
    required this.selectedItems,
    required this.itemQuantities,
  });

  // 선택된 상품 개수 계산
  int _calculateSelectedCount() {
    return currentItems
        .where((item) => selectedItems[item.productId] == true)
        .map((item) => itemQuantities[item.productId] ?? 1)
        .fold(0, (sum, quantity) => sum + quantity);
  }

  @override
  Widget build(BuildContext context) {
    // 현재 탭의 선택된 아이템의 총 금액 계산
    final totalPrice = CartPriceSectionWidget.calculateTotalPrice(
      items: currentItems,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );

    // 선택된 총 상품 개수
    final totalSelectedCount = _calculateSelectedCount();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상품 금액 정보 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '총 $totalSelectedCount건 ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '${formatPrice(totalPrice.toString())}원',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    ' + ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '배송비 0원',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              Text(
                '${formatPrice(totalPrice.toString())}원',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 선물하기/구매하기 버튼
          Row(
            children: [
              // 선물하기 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: totalSelectedCount > 0
                      ? () {
                          // TODO: 선물하기 기능 구현
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('선물하기 기능 준비중입니다.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    '선물하기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 구매하기 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: totalSelectedCount > 0
                      ? () {
                          // 선택된 상품이 있을 때만 결제 페이지로 이동
                          context.push('/payment');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    '구매하기 (${totalSelectedCount})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
