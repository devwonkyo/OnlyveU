// 개별 리뷰 아이템 위젯
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/models/review_model.dart';
import 'package:onlyveyou/screens/Product/widgets/like_button.dart';
import 'package:onlyveyou/utils/string_format.dart';

class ReviewItemWidget extends StatelessWidget {
  final ReviewModel review;
  final String userId;

  const ReviewItemWidget({required this.review, required this.userId});

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
          SizedBox(height: 16.h),
          if (review.imageUrls != null && review.imageUrls!.isNotEmpty)
            _buildReviewImages(),
          SizedBox(height: 16.h),
          LikeButton(review: review, userId: userId,)
        ],
      ),
    );
  }

  Widget _buildReviewHeader() {
    return Row(
      children: [
        review.userProfileImageUrl == "" ? const CircleAvatar(
      backgroundColor: Colors.grey,
      child: Icon(Icons.person, size: 30),
    )
    :
        CircleAvatar(
          backgroundImage: NetworkImage(review.userProfileImageUrl ?? ""),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.userName,
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
                  formatDate(review.createdAt),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9.r), // 원하는 반경 값으로 설정
              child: Image.network(
                review.imageUrls![imageIndex],
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}