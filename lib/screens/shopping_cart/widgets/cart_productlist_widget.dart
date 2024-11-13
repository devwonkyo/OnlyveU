import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/models/cart_model.dart';
import 'package:onlyveyou/utils/format_price.dart';

class CartProductListWidget extends StatelessWidget {
  final List<CartModel> items;
  final bool isPickup;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;
  final Function(String productId, bool increment) onUpdateQuantity;
  final Function(String productId) onRemoveItem;
  final Function(String productId, bool? value) onUpdateSelection;

  const CartProductListWidget({
    super.key,
    required this.items,
    required this.isPickup,
    required this.selectedItems,
    required this.itemQuantities,
    required this.onUpdateQuantity,
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
                  child: Text(
                    '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 체크박스
                  Checkbox(
                    value: selectedItems[item.productId] ?? false,
                    onChanged: (value) =>
                        onUpdateSelection(item.productId, value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // 상품 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
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
                  // 상품 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/product-detail',
                              extra: item.productId),
                          child: Text(
                            item.productName,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 삭제 버튼
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => onRemoveItem(item.productId),
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
                  Text(
                    '${formatPrice(item.productPrice.toString())}원',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantityControl(CartModel item) {
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
              onPressed: () => onUpdateQuantity(item.productId, false),
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
              onPressed: () => onUpdateQuantity(item.productId, true),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
