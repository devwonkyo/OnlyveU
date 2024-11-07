import 'package:flutter/material.dart';
import 'package:onlyveyou/models/product_model.dart';

class HistoryItemCard extends StatelessWidget {
  final ProductModel product; // HistoryItem 대신 ProductModel 사용
  final bool isEditing;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const HistoryItemCard({
    required this.product,
    required this.isEditing,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final price = int.parse(product.price);
    final discountedPrice =
        price - (price * product.discountPercent / 100).round();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 상품 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.productImageList.isNotEmpty
                  ? product.productImageList[0]
                  : '',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.image, size: 100),
            ),
          ),
          SizedBox(width: 16),

          // 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),

                // 원가 (할인이 있는 경우에만 표시)
                if (product.discountPercent > 0)
                  Text(
                    '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                SizedBox(height: 2),

                // 할인율과 판매가
                Row(
                  children: [
                    if (product.discountPercent > 0)
                      Text(
                        '${product.discountPercent}%',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    SizedBox(width: 8),
                    Text(
                      '${discountedPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // 태그 표시
                Row(
                  children: [
                    if (product.isPopular)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '인기',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    if (product.isBest)
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'BEST',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 버튼들
          Column(
            children: [
              if (isEditing)
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: onDelete,
                )
              else
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        product.favoriteList.contains('currentUserId')
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: product.favoriteList.contains('currentUserId')
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: onToggleFavorite,
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                      onPressed: () {
                        // TODO: 장바구니 기능 구현
                      },
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
