import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/review/review_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/review_model.dart';

class LikeButton extends StatefulWidget {
  final ReviewModel review;
  final String userId;

  const LikeButton({
    Key? key,
    required this.review,
    required this.userId,
  }) : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.review.likedUserIds.contains(widget.userId);
    likeCount = widget.review.likedUserIds.length;
  }

  void _handleLikePressed() {
    setState(() {
      if (isLiked) {
        likeCount--;
      } else {
        likeCount++;
      }
      isLiked = !isLiked;
    });

    // Bloc 이벤트 발생
    context.read<ReviewBloc>().add(
        AddReviewLikeEvent(widget.review.reviewId ?? "", widget.userId)
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLikePressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '도움이 돼요',
            style: TextStyle(
              fontSize: 12.0.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 8.0.w),
          Icon(
            Icons.thumb_up,
            color: isLiked ? AppsColor.pastelGreen : Colors.grey,
            size: 14.0.sp,
          ),
          SizedBox(width: 2.0.w),
          Text(
            likeCount.toString(),
            style: TextStyle(
              fontSize: 12.0.sp,
            ),
          ),
        ],
      ),
    );
  }
}