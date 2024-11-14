// 개별 리뷰 아이템 위젯
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/models/review_model.dart';

class ReviewItemWidget extends StatelessWidget {
  final ReviewModel review;

  const ReviewItemWidget({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewHeader(),
          SizedBox(height: 8.h),
          Text(review.content),
          if (review.imageUrls != null && review.imageUrls!.isNotEmpty)
            _buildReviewImages(),
        ],
      ),
    );
  }

  Widget _buildReviewHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage('https://picsum.photos/id/237/100'),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.userId,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                ...List.generate(
                  5,
                      (index) => Icon(
                    Icons.star,
                    color: index < review.rating ? Colors.red : Colors.grey[300],
                    size: 16,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  review.createdAt.toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewImages() {
    return Container(
      height: 80.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: review.imageUrls!.length,
        itemBuilder: (context, imageIndex) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Image.network(
              review.imageUrls![imageIndex],
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}