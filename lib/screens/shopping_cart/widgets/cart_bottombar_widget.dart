import 'package:flutter/material.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_pricesection_widget.dart';
import 'package:onlyveyou/utils/format_price.dart';

class CartBottomBarWidget extends StatelessWidget {
  final List<ProductModel> currentItems;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;

  const CartBottomBarWidget({
    Key? key,
    required this.currentItems,
    required this.selectedItems,
    required this.itemQuantities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 현재 탭의 선택된 아이템만 필터링하여 계산
    final totalPrice = CartPriceSectionWidget.calculateTotalPrice(
      items: currentItems, // 현재 탭의 아이템만 전달
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );

    final totalDiscount = CartPriceSectionWidget.calculateTotalDiscount(
      items: currentItems, // 현재 탭의 아이템만 전달
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );

    final finalPrice = totalPrice - totalDiscount;

    // 현재 탭의 선택된 아이템 수량 계산
    final totalSelectedCount = currentItems
        .where((item) => selectedItems[item.productId] == true)
        .fold(0, (sum, item) => sum + (itemQuantities[item.productId] ?? 1));

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '총 ${totalSelectedCount}건 ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '${formatPrice(finalPrice.toString())}원',
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
                '${formatPrice(finalPrice.toString())}원',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('선물하기'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('구매하기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
