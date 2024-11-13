// 평점 바 아이템 위젯
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingBarItem extends StatelessWidget {
  final int score;
  final double percentage;
  final String displayPercentage;

  const RatingBarItem({
    required this.score,
    required this.percentage,
    required this.displayPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text('$score점', style: TextStyle(fontSize: 12.sp)),
        ),
        Expanded(
          flex: 7,
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(displayPercentage, style: TextStyle(fontSize: 12.sp)),
        ),
      ],
    );
  }
}