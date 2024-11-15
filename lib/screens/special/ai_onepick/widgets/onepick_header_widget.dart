// ai_chat_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIChatHeader extends StatelessWidget {
  final int currentStep;

  const AIChatHeader({
    Key? key,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProgressIndicator(),
        _buildHeaderContent(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          bool isActive = index <= currentStep;
          return Container(
            width: 50.w,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF8B7AFF).withOpacity(0.9)
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? Colors.white
                          : const Color(0xFF8B7AFF).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color:
                            isActive ? Colors.white : const Color(0xFF8B7AFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (index < 4)
                  Container(
                    height: 2,
                    margin: EdgeInsets.only(top: 4.h),
                    color: isActive
                        ? const Color(0xFF8B7AFF).withOpacity(0.9)
                        : const Color(0xFF8B7AFF).withOpacity(0.3),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7AFF).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: const Color(0xFF8B7AFF),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'AI와 대화를 시작해보세요',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B7AFF),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '5개의 질문에 답하시면\nAI가 딱 맞는 상품을 추천해드립니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF8B7AFF).withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
