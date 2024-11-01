import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget ProductItem() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 제품 이미지
      Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              'https://via.placeholder.com/150',
              width: double.infinity,
              height: 180.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 8.w,
            top: 8.h,
            child: Icon(Icons.favorite_border, size: 24.sp, color: Colors.grey),
          ),
        ],
      ),
      SizedBox(height: 8.h),

      // BEST 태그
      Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          'BEST',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(height: 4.h),

      // 제품 정보
      Text(
        '[6년연속 1위] 메디힐 에센셜 마스크팩',
        style: TextStyle(fontSize: 13.sp),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: 4.h),

      // 가격 정보
      Row(
        children: [
          Text(
            '50%',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            '1,000원~',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      // 태그들
      Row(
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '오늘드림',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.pink,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Container(
            margin: EdgeInsets.only(top: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '증정',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}