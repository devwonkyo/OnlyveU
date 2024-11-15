// review_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/review_model.dart';
import 'package:onlyveyou/utils/string_format.dart';

class ReviewItem extends StatelessWidget {
  final ReviewModel reviewModel;

  const ReviewItem({super.key, required this.reviewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Row(
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: DecorationImage(
                    image: NetworkImage(reviewModel.productImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '구매일자 ${formatDate(reviewModel.purchaseDate)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          ' | ',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Text(
                          reviewModel.orderType == OrderType.pickup
                              ? '매장' // orderType이 OrderType.pickup일 때
                              : '배송', // 기본값이거나 OrderType.delivery일 때
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h,),
                    Text(
                      reviewModel.productName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: List.generate(5, (index) {
              if (index < (reviewModel.rating ~/ 1)) {  // 정수부분 (완전 채워진 별)
                return Icon(
                  Icons.star,
                  size: 16.sp,
                  color: Colors.amber,
                );
              } else if (index < reviewModel.rating) {  // 소수부분 (반별)
                return Icon(
                  Icons.star_half,
                  size: 16.sp,
                  color: Colors.amber,
                );
              } else {  // 나머지 (빈 별)
                return Icon(
                  Icons.star_border,
                  size: 16.sp,
                  color: Colors.grey[300],
                );
              }
            }),
          ),
          SizedBox(height: 8.h),
          Text(
            '작성일자 ${formatDate(reviewModel.createdAt)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            reviewModel.content,
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: 리뷰 수정
                  },
                  child: Text('리뷰수정'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}