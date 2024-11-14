// ranking_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/ranking_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/utils/styles.dart';

class RankingCardWidget extends StatelessWidget {
  final int index; // 상품의 순위를 나타내는 인덱스
  final ProductModel product; // 상품 정보를 담고 있는 모델 객체

  const RankingCardWidget({
    Key? key,
    required this.index,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final originalPrice = int.parse(product.price); // 원래 가격
    final discountedPrice =
        originalPrice * (100 - product.discountPercent) ~/ 100; // 할인 적용된 가격
    final formattedRating = product.rating.toStringAsFixed(1); // 별점 (소수점 1자리)

    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: product.productId),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지와 순위 표시
            Stack(
              children: [
                // 상품 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.productImageList.first,
                    width: double.infinity,
                    height: 180.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.image, size: 180.h),
                  ),
                ),
                // 상위 3위까지는 메인 컬러로 순위 표시
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
                      '${index + 1}', // 순위 표시
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
            // 상품 상세 정보
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품명
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    // 원래 가격 (취소선)
                    Text(
                      '${originalPrice.toString()}원',
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // 할인율과 할인 적용된 가격
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
                        Flexible(
                          child: Text(
                            '${discountedPrice}원', // 할인 가격 표시
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '인기',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
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
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BEST',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6),
                    // 별점과 리뷰 수
                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 16.sp, color: AppStyles.mainColor),
                        SizedBox(width: 4.w),
                        Text(
                          formattedRating, // 소수점 한 자리로 포맷된 별점
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '(${product.reviewList.length})', // 리뷰 수
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // 찜하기 및 장바구니 아이콘

                    Row(
                      children: [
                        FutureBuilder<String>(
                          future: OnlyYouSharedPreference().getCurrentUserId(),
                          builder: (context, snapshot) {
                            final userId = snapshot.data ?? 'temp_user_id';
                            return GestureDetector(
                              onTap: () async {
                                print('좋아요 누른 상품 ID: ${product.productId}');
                                final prefs = OnlyYouSharedPreference();
                                final currentUserId =
                                    await prefs.getCurrentUserId();
                                context.read<RankingBloc>().add(
                                      ToggleProductFavorite(product,
                                          currentUserId), //^ LoadRankingProducts에서 ToggleProductFavorite로 변경
                                    );
                              },
                              child: Icon(
                                product.favoriteList.contains(userId)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20.sp,
                                color: product.favoriteList.contains(userId)
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 16.w),
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
                              color: Colors.grey,
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
