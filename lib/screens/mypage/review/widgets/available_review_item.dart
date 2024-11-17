// review_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/models/available_review_model.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/review_model.dart';
import 'package:onlyveyou/utils/string_format.dart';

class AvailableReviewItem extends StatelessWidget {
  final AvailableOrderModel reviewModel;

  const AvailableReviewItem({super.key, required this.reviewModel});

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
                    image: NetworkImage(reviewModel.orderItem.productImageUrl),
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
                      reviewModel.orderItem.productName,
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
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    reviewModel.orderItem.reviewId == null
                        ? () {
                      context.push("/write_rating", extra: reviewModel);
                    }
                    : null; // reviewId가 null이 아닐 때는 버튼 비활성화
                  },
                  child: Text('리뷰 쓰기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w), // 원하는 radius 값 설정
                    ),
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