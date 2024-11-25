// 1번 위젯: 평점 요약
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/models/review_model.dart';
import 'package:onlyveyou/screens/Product/widgets/ratingbar_item.dart';

class ReviewSummaryWidget extends StatelessWidget {
  final List<ReviewModel> reviewList;
  final double ratingAverage;
  final Map<int,double> ratingPercentAge;

  const ReviewSummaryWidget({super.key, required this.reviewList, required this.ratingAverage, required this.ratingPercentAge});

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
    String emoji;
    if (ratingAverage >= 4) {
      emoji = '🌟'; // 4~5점
    } else if (ratingAverage >= 2) {
      emoji = '😊'; // 2~4점
    } else {
      emoji = '😟'; // 1~2점
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            shape: BoxShape.circle,
          ),
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 24.sp, // 이모티콘이므로 텍스트 크기를 크게 조정
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '총 ${reviewList.length}건',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ratingAverage.toString(),
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
        ),
      ],
    );
  }

  Widget _buildRatingBars() {
    return Column(
      children: [
        RatingBarItem(score: 5, percentage: ratingPercentAge[5] ?? 0, displayPercentage: '${((ratingPercentAge[5] ?? 0) * 100).toStringAsFixed(0)}%'),
        RatingBarItem(score: 4, percentage: ratingPercentAge[4] ?? 0, displayPercentage: '${((ratingPercentAge[4] ?? 0) * 100).toStringAsFixed(0)}%'),
        RatingBarItem(score: 3, percentage: ratingPercentAge[3] ?? 0, displayPercentage: '${((ratingPercentAge[3] ?? 0) * 100).toStringAsFixed(0)}%'),
        RatingBarItem(score: 2, percentage: ratingPercentAge[2] ?? 0, displayPercentage: '${((ratingPercentAge[2] ?? 0) * 100).toStringAsFixed(0)}%'),
        RatingBarItem(score: 1, percentage: ratingPercentAge[1] ?? 0, displayPercentage: '${((ratingPercentAge[1] ?? 0) * 100).toStringAsFixed(0)}%'),
      ],
    );
  }
}