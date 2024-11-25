// recommended_products_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/utils/styles.dart';

class RecommendedProductsWidget extends StatelessWidget {
  final List<ProductModel> recommendedProducts;
  final bool isPortrait;
  final String userId;

  RecommendedProductsWidget({
    required this.recommendedProducts,
    required this.isPortrait,
    required this.userId,
    Key? key,
  }) : super(key: key);

  String _formatPrice(String price) {
    try {
      return price.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    } catch (e) {
      return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? AppsColor.darkGray : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppStyles.defaultPadding,
            child: FutureBuilder<String>(
              future: OnlyYouSharedPreference().getNickname(),
              builder: (context, snapshot) {
                final nickname = snapshot.data ?? '고객';
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$nickname님을 위한 추천상품',
                      style: AppStyles.headingStyle.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/more-recommended'),
                      child: Text(
                        '더보기 >',
                        style: AppStyles.bodyTextStyle.copyWith(
                          color: isDarkMode
                              ? Colors.grey[400]
                              : AppStyles.greyColor,
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          SizedBox(
            height: isPortrait ? 340 : 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendedProducts.length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) =>
                  _buildProductCard(context, index, isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index, bool isDarkMode) {
    final item = recommendedProducts[index];

    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: item.productId),
      child: Container(
        width: 150,
        margin: EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.productImageList.isNotEmpty
                    ? Image.network(
                        item.productImageList.first,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.error,
                              color:
                                  isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            if (item.discountPercent > 0)
              Text(
                '${_formatPrice(item.price)}원',
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey,
                  fontSize: 12,
                ),
              ),
            SizedBox(height: 2),
            Row(
              children: [
                if (item.discountPercent > 0)
                  Text(
                    '${item.discountPercent}%',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                SizedBox(width: 4),
                Text(
                  '${_formatPrice(item.discountedPrice.toString())}원',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                if (item.isPopular)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '인기',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                SizedBox(width: 4),
                if (item.isBest)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'BEST',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 12,
                  color: AppStyles.mainColor,
                ),
                SizedBox(width: 2),
                Text(
                  item.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(width: 2),
                Text(
                  '(${item.reviewCount})',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    print('Recommended Product ID: ${item.productId}');
                    context
                        .read<HomeBloc>()
                        .add(ToggleProductFavorite(item, userId));
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    child: Icon(
                      item.isFavorite(userId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
                      color: item.isFavorite(userId)
                          ? Colors.red
                          : (isDarkMode ? Colors.grey[400] : Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: 25),
                GestureDetector(
                  onTap: () {
                    context.read<HomeBloc>().add(AddToCart(item.productId));
                    context.read<HomeBloc>().stream.listen(
                      (state) {
                        if (state is HomeError || state is HomeSuccess) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state is HomeSuccess
                                  ? state.message
                                  : (state as HomeError).message),
                              duration: Duration(milliseconds: 1000),
                            ),
                          );
                        }
                      },
                    );
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 20,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
