// 2번 위젯: 리뷰 목록
import 'package:flutter/material.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/review_model.dart';
import 'package:onlyveyou/screens/Product/widgets/review_item_widget.dart';

class ReviewListWidget extends StatelessWidget {
  final List<ReviewModel> reviewList;
  final String userId;

  const ReviewListWidget({super.key, required this.reviewList, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reviewList.length,
      separatorBuilder: (context, index) => Divider(color: AppsColor.lightGray,),
      itemBuilder: (context, index) => ReviewItemWidget(review: reviewList[index], userId:  userId,),
    );
  }
}