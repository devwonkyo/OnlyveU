// 세로 리스트 상품 카드
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/format_price.dart';

class VerticalProductCard extends StatelessWidget {
  final ProductModel productModel;
  final VoidCallback? onTap;
  final bool isBest;

  const VerticalProductCard({
    Key? key,
    required this.productModel,
    this.onTap,
    this.isBest = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                child: productModel.productImageList.isNotEmpty
                    ? Image.network(
                  productModel.productImageList.first,
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
              productModel.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4.h),

            // 3. 가격 정보
            if (productModel.discountPercent > 0)
              Text(
                '${productModel.price}원',
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),
            SizedBox(height: 2.h),
            Row(
              children: [
                if (productModel.discountPercent > 0)
                  Text(
                    '${productModel.discountPercent}%',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                SizedBox(width: 4.w),
                Text(
                  '${formatDiscountedPriceToString(productModel.price,productModel.discountPercent.toDouble())}원',
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
                if (productModel.isPopular)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
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
                if (productModel.isBest)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
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
                  productModel.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '(${productModel.reviewList.length})',
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
                  onTap: () {},
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    child: Icon(
                      productModel.isFavorite("userId")
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18.sp,
                      color: productModel.isFavorite("userId") ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
                SizedBox(width: 25.w),
                GestureDetector(
                  onTap: () {},
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