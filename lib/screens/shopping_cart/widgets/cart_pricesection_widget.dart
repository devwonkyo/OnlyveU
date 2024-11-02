import 'package:flutter/material.dart';

import '../../../models/product_model.dart';

//가격계산
class CartPriceSectionWidget extends StatelessWidget {
  final List<ProductModel> items;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;

  const CartPriceSectionWidget({
    required this.items,
    required this.selectedItems,
    required this.itemQuantities,
  });

  // calculateTotalPrice를 static으로 변경
  static int calculateTotalPrice({
    required List<ProductModel> items,
    required Map<String, bool> selectedItems,
    required Map<String, int> itemQuantities,
  }) {
    return items.fold(0, (sum, item) {
      if (selectedItems[item.productId] == true) {
        int quantity = itemQuantities[item.productId] ?? 1;
        return sum + (int.parse(item.price) * quantity);
      }
      return sum;
    });
  }

  // calculateTotalDiscount를 static으로 변경
  static int calculateTotalDiscount({
    required List<ProductModel> items,
    required Map<String, bool> selectedItems,
    required Map<String, int> itemQuantities,
  }) {
    return items.fold(0, (sum, item) {
      if (selectedItems[item.productId] == true) {
        int quantity = itemQuantities[item.productId] ?? 1;
        int originalPrice = int.parse(item.price);
        int discountedPrice = item.discountedPrice;
        return sum + ((originalPrice - discountedPrice) * quantity);
      }
      return sum;
    });
  }

  String formatPrice(String price) {
    return price.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = calculateTotalPrice(
      items: items,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );
    final totalDiscount = calculateTotalDiscount(
      items: items,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );
    final finalPrice = totalPrice - totalDiscount;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 상품금액'),
              Text('${formatPrice(totalPrice.toString())}원',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 할인금액'),
              Text('${formatPrice(totalDiscount.toString())}원',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 배송비'),
              Text('0원', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(height: 32),
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
