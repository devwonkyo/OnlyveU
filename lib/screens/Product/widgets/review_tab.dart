import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/models/review_model.dart';

class ReviewTab extends StatelessWidget {
  final List<ReviewModel> reviews;

  const ReviewTab({Key? key, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => Divider(height: 1.h),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 리뷰 작성자 정보
              Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundImage: NetworkImage(review.userId),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    review.userId,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Text(
                    review.createdAt as String,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // 별점
              Row(
                children: [
                  ...List.generate(5, (index) => Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 16.r,
                    color: Colors.amber,
                  )),
                ],
              ),
              SizedBox(height: 8.h),

              // 리뷰 내용
              Text(
                review.content,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),

              // 리뷰 이미지가 있는 경우
              if (review.imageUrls != null && review.imageUrls!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: review.imageUrls!.map((imageUrl) => Container(
                        margin: EdgeInsets.only(right: 8.w),
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}