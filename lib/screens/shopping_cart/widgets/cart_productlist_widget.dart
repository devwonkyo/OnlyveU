import 'package:flutter/material.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';
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
    super.key,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPickup)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
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
                    child: Image.network(
                      // .asset에서 .network로 변경
                      item.productImageList.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error'); // 에러 로깅 추가
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        // 로딩 상태 표시 추가
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => onRemoveItem(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 50),
                  _buildQuantityControl(item),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${formatPrice(item.price)}원',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${formatPrice(item.discountedPrice.toString())}원',
                        style: const TextStyle(
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
              icon: const Icon(Icons.remove, size: 16),
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
              style: const TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => updateQuantity(item.productId, true),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
