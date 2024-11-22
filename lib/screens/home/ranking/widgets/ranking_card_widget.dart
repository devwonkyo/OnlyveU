import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/ranking_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/format_price.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/utils/styles.dart';

class RankingCardWidget extends StatelessWidget {
  final int index;
  final ProductModel product;

  const RankingCardWidget({
    Key? key,
    required this.index,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final originalPrice = int.parse(product.price);
    final discountedPrice =
        originalPrice * (100 - product.discountPercent) ~/ 100;
    final formattedRating = product.rating.toStringAsFixed(1);

    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: product.productId),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.productImageList.first,
                    width: double.infinity,
                    height: 160.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160.h,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        size: 40.h,
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index < 3 ? AppStyles.mainColor : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${formatPrice(product.price)}원',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '${product.discountPercent}%',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${formatDiscountedPriceToString(product.price, product.discountPercent.toDouble())}원',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        if (product.isPopular)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '인기',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        if (product.isPopular && product.isBest)
                          SizedBox(width: 6),
                        if (product.isBest)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BEST',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 16.sp, color: AppStyles.mainColor),
                        SizedBox(width: 4.w),
                        Text(
                          formattedRating,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '(${product.reviewList.length})',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        FutureBuilder<String>(
                          future: OnlyYouSharedPreference().getCurrentUserId(),
                          builder: (context, snapshot) {
                            final userId = snapshot.data ?? 'temp_user_id';
                            return GestureDetector(
                              onTap: () {
                                print(
                                    'Ranking Product ID: ${product.productId}');
                                context.read<RankingBloc>().add(
                                      ToggleProductFavorite(product, userId),
                                    );
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                child: Icon(
                                  product.favoriteList.contains(userId)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: product.favoriteList.contains(userId)
                                      ? Colors.red
                                      : (isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 25),
                        GestureDetector(
                          onTap: () async {
                            context
                                .read<RankingBloc>()
                                .add(AddToCart(product.productId));

                            context.read<RankingBloc>().stream.listen(
                              (state) {
                                if (state is RankingError ||
                                    state is RankingSuccess) {
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(state is RankingSuccess
                                          ? state.message
                                          : (state as RankingError).message),
                                      duration: Duration(milliseconds: 1000),
                                      backgroundColor:
                                          isDarkMode ? Colors.grey[800] : null,
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
                              color:
                                  isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
