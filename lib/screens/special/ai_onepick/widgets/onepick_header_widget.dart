// AIChatHeader 위젯은 대화 진행 단계와 헤더 콘텐츠를 표시하는 컴포넌트입니다.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIChatHeader extends StatelessWidget {
  // 현재 진행 단계 (0~4 범위)
  final int currentStep;

  const AIChatHeader({
    Key? key,
    required this.currentStep, // 필수 매개변수로 현재 진행 단계 전달
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProgressIndicator(), // 진행 단계를 나타내는 인디케이터
        _buildHeaderContent(), // 헤더의 메시지와 아이콘을 포함하는 콘텐츠
      ],
    );
  }

  // 진행 단계를 표시하는 인디케이터 빌드  -블록으로 안하고, 화면 안에서는 상태관리 안쓴느게 좋다
  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h), // 세로 패딩 추가
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
        children: List.generate(5, (index) {
          // 5단계의 원형 인디케이터를 생성
          bool isActive = index <= currentStep; // 현재 단계 이하인지 확인
          return Container(
            width: 50.w, // 인디케이터 간격
            margin: EdgeInsets.symmetric(horizontal: 4.w), // 좌우 마진
            child: Column(
              children: [
                // 원형 인디케이터
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF8B7AFF).withOpacity(0.9) // 활성화 상태 색상
                        : Colors.white, // 비활성화 상태 색상
                    shape: BoxShape.circle, // 원형
                    border: Border.all(
                      color: isActive
                          ? Colors.white // 활성화 상태 테두리
                          : const Color(0xFF8B7AFF)
                              .withOpacity(0.3), // 비활성화 상태 테두리
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}', // 단계 숫자
                      style: TextStyle(
                        color: isActive
                            ? Colors.white // 활성화 상태 텍스트 색상
                            : const Color(0xFF8B7AFF), // 비활성화 상태 텍스트 색상
                        fontWeight: FontWeight.bold, // 굵은 텍스트
                      ),
                    ),
                  ),
                ),
                // 단계 사이의 선
                if (index < 4) // 마지막 단계에는 선을 추가하지 않음
                  Container(
                    height: 2, // 선의 높이
                    margin: EdgeInsets.only(top: 4.h), // 위쪽 마진
                    color: isActive
                        ? const Color(0xFF8B7AFF)
                            .withOpacity(0.9) // 활성화 상태 선 색상
                        : const Color(0xFF8B7AFF)
                            .withOpacity(0.3), // 비활성화 상태 선 색상
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // 헤더 메시지와 아이콘을 표시하는 콘텐츠 빌드
  Widget _buildHeaderContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h), // 내부 패딩
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
            children: [
              // 원형 아이콘 배경
              Container(
                padding: EdgeInsets.all(8.w), // 내부 여백
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7AFF).withOpacity(0.2), // 배경 색상
                  shape: BoxShape.circle, // 원형
                ),
                child: Icon(
                  Icons.auto_awesome, // 아이콘
                  color: const Color(0xFF8B7AFF), // 아이콘 색상
                  size: 20.sp, // 반응형 아이콘 크기
                ),
              ),
              SizedBox(width: 12.w), // 아이콘과 텍스트 간격
              Text(
                'AI와 대화를 시작해보세요', // 헤더 텍스트
                style: TextStyle(
                  fontSize: 22.sp, // 반응형 텍스트 크기
                  fontWeight: FontWeight.bold, // 굵은 텍스트
                  color: const Color(0xFF8B7AFF), // 텍스트 색상
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h), // 텍스트 간격
          Text(
            '5개의 질문에 답하시면\nAI가 딱 맞는 상품을 추천해드립니다', // 설명 텍스트
            textAlign: TextAlign.center, // 중앙 정렬
            style: TextStyle(
              fontSize: 14.sp, // 반응형 텍스트 크기
              color: const Color(0xFF8B7AFF).withOpacity(0.8), // 텍스트 색상
              height: 1.6, // 줄 간격
            ),
          ),
        ],
      ),
    );
  }
}
