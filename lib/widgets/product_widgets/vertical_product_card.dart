// 세로 리스트 상품 카드
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/category/category_product_bloc.dart';
import 'package:onlyveyou/blocs/product/cart/product_cart_bloc.dart';
import 'package:onlyveyou/blocs/product/like/product_like_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/format_price.dart';

class VerticalProductCard extends StatefulWidget {
  final ProductModel productModel;
  final String userId;
  final VoidCallback? onTap;
  final bool isBest;

  const VerticalProductCard({
    Key? key,
    required this.productModel,
    this.onTap,
    this.isBest = false,
    required this.userId,
  }) : super(key: key);

  @override
  State<VerticalProductCard> createState() => _VerticalProductCardState();
}

class _VerticalProductCardState extends State<VerticalProductCard> {
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = widget.productModel.isFavorite(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 150.w,
        margin: EdgeInsets.only(right: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상품 이미지
            Container(
              width: 150.w,
              height: 150.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: widget.productModel.productImageList.isNotEmpty
                    ? Image.network(
                        widget.productModel.productImageList.first,
                        width: 150.w,
                        height: 150.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Icon(Icons.error, size: 24.sp));
                        },
                      )
                    : Image.asset(
                        'assets/default_image.png',
                        width: 150.w,
                        height: 150.w,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(height: 8.h),

            // 2. 상품명
            Text(
              widget.productModel.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4.h),

            // 3. 가격 정보
            if (widget.productModel.discountPercent > 0)
              Text(
                '${widget.productModel.price}원',
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),
            SizedBox(height: 2.h),
            Row(
              children: [
                if (widget.productModel.discountPercent > 0)
                  Text(
                    '${widget.productModel.discountPercent}%',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                SizedBox(width: 4.w),
                Text(
                  '${formatDiscountedPriceToString(widget.productModel.price, widget.productModel.discountPercent.toDouble())}원',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),

            // 4. 태그들
            Row(
              children: [
                if (widget.productModel.isPopular)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '인기',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                SizedBox(width: 4.w),
                if (widget.productModel.isBest)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'BEST',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),

            // 5. 별점과 리뷰 수
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 12.sp,
                  color: AppsColor.pastelGreen,
                ),
                SizedBox(width: 2.w),
                Text(
                  widget.productModel.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '(${widget.productModel.reviewList.length})',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),

            // 6. 좋아요와 장바구니 버튼
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // 좋아요 상태 전환 이벤트 디스패치
                    setState(() {
                      isLiked = !isLiked;
                    });
                    BlocProvider.of<ProductLikeBloc>(context).add(
                        AddToLikeEvent(
                            userId: widget.userId,
                            productId: widget.productModel.productId,
                        ));
                  },
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18.sp,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
                SizedBox(width: 25.w),
                GestureDetector(
                  onTap: () {
                    context
                        .read<ProductCartBloc>()
                        .add(AddToCartEvent(widget.productModel));
                  },
                  child: Container(
                    width: 22.w,
                    height: 22.w,
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 20.sp,
                      color: Colors.grey,
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
