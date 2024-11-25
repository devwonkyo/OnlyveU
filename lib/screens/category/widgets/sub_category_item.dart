import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/config/theme.dart';

class SubCategoryItem extends StatelessWidget {
  final String title;

  const SubCategoryItem({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: getBackgroundColor(context),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          color: getDarkModeTextColor(context),
        ),
      ),
    );
  }
}