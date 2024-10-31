import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget FilterItem(String text, bool isSelected) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: isSelected ? Colors.black : Colors.transparent,
          width: 2.h,
        ),
      ),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.black : Colors.grey,
      ),
    ),
  );
}