import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/special_bloc/ai_onepick_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/special/ai_onepick_repository.dart';

// AIChatContent 위젯은 AI 채팅 대화 영역과 사용자 입력 영역을 포함한 UI를 제공합니다.
class AIChatContent extends StatelessWidget {
  // 채팅 메시지 리스트
  final List<Map<String, String>> messages;
  // 스크롤 동작을 위한 ScrollController
  final ScrollController scrollController;
  // 텍스트 입력을 관리하는 TextEditingController
  final TextEditingController textController;
  // 메시지를 전송할 때 호출되는 콜백
  final Function(String) onSendMessage;
  // 로딩 상태 플래그
  final bool isLoading;
  // 추천된 상품 정보
  final ProductModel? recommendedProduct;
  // 추천 이유
  final String? recommendationReason;

  const AIChatContent({
    Key? key,
    required this.messages,
    required this.scrollController,
    required this.textController,
    required this.onSendMessage,
    required this.isLoading,
    this.recommendedProduct,
    this.recommendationReason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repository = context.read<AIOnepickRepository>();
    final currentStep = repository.currentStep; // 현재 단계 가져오기

    return Column(
      children: [
        // 채팅 영역
        Expanded(
          child: Stack(
            children: [
              _buildChatArea(), // 채팅 메시지를 표시하는 ListView
              if (isLoading)
                Positioned.fill(
                  // 로딩 상태 시 화면에 로딩 인디케이터 표시
                  child: Container(
                    color: Colors.black12,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 단계에 따라 입력 영역 또는 "한번 더 하기" 버튼 표시
        if (currentStep >= 5)
          _buildOneMoreButton(context) // 5단계 완료 시 "한번 더 하기" 버튼
        else
          _buildInputArea(context), // 진행 중일 경우 입력 필드
      ],
    );
  }

  // 채팅 메시지 리스트 영역 빌드
  Widget _buildChatArea() {
    // 스크롤 위치를 자동으로 하단으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    // 페이드 아웃 효과를 위한 ShaderMask 적용
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white, // 상단은 완전 불투명
            Colors.transparent, // 하단은 점점 투명
            Colors.transparent,
          ],
          stops: [0.0, 0.1, 0.7],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstOut, // 투명도 블렌드 모드
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 8.h,
          bottom: 16.h,
        ),
        itemCount: messages.length, // 메시지 개수
        itemBuilder: (context, index) {
          final message = messages[index];
          return _buildMessageBubble(
            context,
            message['content'] ?? '', // 메시지 내용
            message['role'] == 'assistant', // AI 메시지 여부
            index,
          );
        },
      ),
    );
  }

  // 개별 메시지 버블 빌드
  Widget _buildMessageBubble(
      BuildContext context, String text, bool isAI, int messageIndex) {
    // 추천 상품 메시지일 경우
    if (isAI &&
        recommendedProduct != null &&
        messageIndex == messages.length - 1 &&
        context.read<AIOnepickRepository>().currentStep == 5) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI 아이콘
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF8B7AFF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: const Color(0xFF8B7AFF),
                size: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 메시지 텍스트 버블
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: const Color(0xFF8B7AFF),
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // 추천 상품 카드
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () => context.push(
                        '/product-detail', // 상품 상세 경로
                        extra: recommendedProduct!.productId, // 상품 ID 전달
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상품 이미지
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.r),
                            ),
                            child: Image.network(
                              recommendedProduct!.productImageList.first,
                              height: 120.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recommendedProduct!.brandName, // 브랜드 이름
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  recommendedProduct!.name, // 상품 이름
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  recommendationReason ?? '', // 추천 이유
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF8B7AFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 일반 메시지 버블
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment:
            isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAI) ...[
            // AI 아이콘
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF8B7AFF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: const Color(0xFF8B7AFF),
                size: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          // 메시지 버블
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isAI
                    ? Colors.white
                    : const Color(0xFF8B7AFF).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isAI ? const Color(0xFF8B7AFF) : Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5단계 완료 시 표시되는 버튼
  Widget _buildOneMoreButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () =>
            context.read<AIOnepickBloc>().add(ResetChat()), // 채팅 초기화 이벤트
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B7AFF),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              '한번 더 하기', // 버튼 텍스트
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 채팅 입력 영역
  Widget _buildInputArea(BuildContext context) {
    final repository = context.read<AIOnepickRepository>();
    final currentStep = repository.currentStep; // 현재 단계 가져오기

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 텍스트 입력 필드
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8B7AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: textController,
                enabled: !isLoading && currentStep < 5, // 입력 가능 조건
                style: TextStyle(color: const Color(0xFF8B7AFF)),
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요...', // 힌트 텍스트
                  hintStyle: TextStyle(
                    color: const Color(0xFF8B7AFF).withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                onSubmitted: onSendMessage, // 메시지 전송 콜백
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // 전송 버튼
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8B7AFF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: (isLoading || currentStep >= 5)
                  ? null // 비활성화 조건
                  : () => onSendMessage(textController.text), // 전송 동작
            ),
          ),
        ],
      ),
    );
  }
}
