import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIRecommendEmptyState extends StatelessWidget {
  const AIRecommendEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40.h), // 상단 여백 추가
              Container(
                width: 150.w, // 크기 축소
                height: 150.w, // 크기 축소
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.psychology_outlined,
                    size: 65.w, // 크기 축소
                    color: Colors.blue.shade300,
                  ),
                ),
              ),
              SizedBox(height: 24.h), // 간격 축소
              Text(
                'AI 추천을 시작해보세요',
                style: TextStyle(
                  fontSize: 20.sp, // 크기 축소
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12.h), // 간격 축소
              Text(
                '회원님의 취향을 분석하여\n맞춤형 상품을 추천해드립니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp, // 크기 축소
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h), // 간격 축소
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeatureItem(Icons.bolt_outlined, '빠른 분석'),
                  SizedBox(width: 24.w),
                  _buildFeatureItem(Icons.auto_awesome_outlined, '맞춤 추천'),
                ],
              ),
              SizedBox(height: 40.h), // 하단 여백 추가
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14.sp, // 크기 축소
          color: Colors.grey.shade600,
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp, // 크기 축소
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
