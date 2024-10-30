import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppStyles {
  // 색상
  static const Color mainColor = Color(0xFFC9C138);
  static const Color greyColor = Colors.grey;

  // 텍스트 스타일
  static TextStyle get headingStyle => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      );

  static TextStyle get subHeadingStyle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      );

  static TextStyle get bodyTextStyle => TextStyle(
        fontSize: 14.sp,
        color: Colors.black,
      );

  static TextStyle get smallTextStyle => TextStyle(
        fontSize: 12.sp,
        color: greyColor,
      );

  static TextStyle get priceTextStyle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      );

  static TextStyle get discountTextStyle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: mainColor,
      );

  // 패딩
  static EdgeInsets get defaultPadding => EdgeInsets.all(16.w);
  static EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: 8.h);

  // 카드 관련
  static double get productCardWidth => 150.w;
  static double get productCardHeight => 150.h;
  static double get productCardSpacing => 12.w;
  static BorderRadius get defaultRadius => BorderRadius.circular(8.w);
}
