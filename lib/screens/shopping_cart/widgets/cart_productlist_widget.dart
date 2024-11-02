import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/format_price.dart';

import '../../../models/product_model.dart';

//이것도 탭 헤더에 물려있어서 따로 안해도 된다.// utils.dart 파일 임포트
// 상품 리스트
class CartProductListWidget extends StatelessWidget {
  final List<ProductModel> items;
  final bool isPickup;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;
  final Function(String productId, bool increment) updateQuantity;
  final Function(ProductModel item) onRemoveItem;
  final Function(String productId, bool? value) onUpdateSelection;

  const CartProductListWidget({
    required this.items,
    required this.isPickup,
    required this.selectedItems,
    required this.itemQuantities,
    required this.updateQuantity,
    required this.onRemoveItem,
    required this.onUpdateSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPickup)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('픽업 매장: 거여역점',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: selectedItems[item.productId] ?? false,
                    onChanged: (value) =>
                        onUpdateSelection(item.productId, value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.productImageList.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20),
                    onPressed: () => onRemoveItem(item),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(width: 50),
                  _buildQuantityControl(item),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${formatPrice(item.price)}원', // formatPrice 호출
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${formatPrice(item.discountedPrice.toString())}원', // formatPrice 호출
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantityControl(ProductModel item) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              icon: Icon(Icons.remove, size: 16),
              onPressed: () => updateQuantity(item.productId, false),
              padding: EdgeInsets.zero,
            ),
          ),
          Container(
            width: 30,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              '${itemQuantities[item.productId] ?? 1}',
              style: TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              icon: Icon(Icons.add, size: 16),
              onPressed: () => updateQuantity(item.productId, true),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
