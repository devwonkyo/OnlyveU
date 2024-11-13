// 2번 위젯: 리뷰 목록
import 'package:flutter/material.dart';
import 'package:onlyveyou/models/review_model.dart';
import 'package:onlyveyou/screens/Product/widgets/review_item_widget.dart';

class ReviewListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 10,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) => ReviewItemWidget(review: _getDummyReview()),
    );
  }

  ReviewModel _getDummyReview() {
    return ReviewModel(
      reviewId: '1',
      productId: 'product123',
      userId: '골드올챙이',
      rating: 5,
      content: '''일단은 맛이 있으니까 꾸준히 챙겨먹게 되요!...''',
      createdAt: DateTime(2024, 11, 11),
      imageUrls: [
        'https://picsum.photos/id/237/100',
        'https://picsum.photos/id/237/100'
      ],
    );
  }
}