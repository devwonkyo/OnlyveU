import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArGuideOverlay extends StatelessWidget {
  final VoidCallback onSkip;

  const ArGuideOverlay({
    Key? key,
    required this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 반투명 오버레이 배경
        Container(
          color: Colors.black.withOpacity(0.7),
        ),

        // 얼굴 가이드 영역
        Center(
          child: Container(
            width: 250.w,
            height: 300.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2.w,
              ),
              borderRadius: BorderRadius.circular(150.r),
            ),
          ),
        ),

        // 가이드 텍스트
        Positioned(
          top: 100.h,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Icon(
                Icons.face,
                color: Colors.white,
                size: 40.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                '얼굴을 화면 중앙에 맞춰주세요',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // 팁 목록
        Positioned(
          bottom: 120.h,
          left: 20.w,
          right: 20.w,
          child: Column(
            children: [
              _buildTip(Icons.face, '입술 라인을 정확히 맞춰주세요'),
              _buildTip(Icons.wb_sunny, '자연광에서 확인하는 것을 추천드려요'),
              _buildTip(Icons.touch_app, '여러 번 테스트해보세요'),
            ],
          ),
        ),

        // 시작하기 버튼
        Positioned(
          bottom: 40.h,
          left: 20.w,
          right: 20.w,
          child: ElevatedButton(
            onPressed: onSkip,
            child: Text('시작하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade400,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
