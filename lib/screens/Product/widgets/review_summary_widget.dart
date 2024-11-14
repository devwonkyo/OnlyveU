// 1번 위젯: 평점 요약
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/screens/Product/widgets/ratingbar_item.dart';

class ReviewSummaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildSummaryHeader(),
          SizedBox(height: 16.h),
          _buildRatingBars(),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            shape: BoxShape.circle,
          ),
          child: Text(
            '최고',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '총 158건',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
            Row(
              children: [
                Text(
                  '4.9',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '점',
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingBars() {
    return Column(
      children: [
        RatingBarItem(score: 5, percentage: 0.95, displayPercentage: '95%'),
        RatingBarItem(score: 4, percentage: 0.25, displayPercentage: '25%'),
        RatingBarItem(score: 3, percentage: 0.15, displayPercentage: '15%'),
      ],
    );
  }
}