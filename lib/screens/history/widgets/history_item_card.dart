import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/history/history_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

class HistoryItemCard extends StatelessWidget {
  final ProductModel product;
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

    return FutureBuilder<String>(
      future: OnlyYouSharedPreference().getCurrentUserId(),
      builder: (context, snapshot) {
        final userId = snapshot.data ?? '';

        return GestureDetector(
          onTap: () =>
              context.push('/product-detail', extra: product.productId),
          child: Container(
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
                      // 태그 표시
                      Row(
                        children: [
                          if (product.isPopular)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '인기',
                                style: TextStyle(
                                  fontSize: 12,
                                  // 다크모드일 때는 검은색, 아닐 때는 현재 색상 유지
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : null,
                                ),
                              ),
                            ),
                          if (product.isBest)
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BEST',
                                style: TextStyle(
                                  fontSize: 12,
                                  // 다크모드일 때는 검은색, 아닐 때는 현재 색상 유지
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : null,
                                ),
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
                              product.favoriteList.contains(userId)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: product.favoriteList.contains(userId)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: onToggleFavorite,
                          ),
                          GestureDetector(
                            onTap: () async {
                              try {
                                context
                                    .read<HistoryBloc>()
                                    .add(AddToCart(product.productId));

                                context.read<HistoryBloc>().stream.listen(
                                  (state) {
                                    if (state is HistorySuccess) {
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(state.message),
                                          duration:
                                              Duration(milliseconds: 1000),
                                        ),
                                      );
                                    }
                                  },
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    duration: Duration(milliseconds: 1000),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
