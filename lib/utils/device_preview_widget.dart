// device_preview_widget.dart 파일 생성
import 'package:flutter/material.dart';

import 'screen_util.dart';

class DevicePreviewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '📱 디바이스 정보',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '너비: ${ScreenUtil.screenWidth.toStringAsFixed(1)}',
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
          Text(
            '높이: ${ScreenUtil.screenHeight.toStringAsFixed(1)}',
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
          Text(
            '방향: ${MediaQuery.of(context).orientation.name}',
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
          Text(
            '비율: ${(ScreenUtil.screenWidth / ScreenUtil.screenHeight).toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
