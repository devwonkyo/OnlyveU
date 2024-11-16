import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/models/product_model.dart';

class AIChatContent extends StatelessWidget {
  final List<Map<String, String>> messages;
  final ScrollController scrollController;
  final TextEditingController textController;
  final Function(String) onSendMessage;
  final bool isLoading;
  final ProductModel? recommendedProduct;
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
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              _buildChatArea(),
              if (isLoading)
                Positioned.fill(
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
        _buildInputArea(),
      ],
    );
  }

  Widget _buildChatArea() {
//채팅 생길때마다 자동 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.transparent,
            Colors.transparent,
          ],
          stops: [0.0, 0.1, 0.7],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstOut,
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return _buildMessageBubble(
            context,
            message['content'] ?? '',
            message['role'] == 'assistant',
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String text, bool isAI) {
    // AI가 제품을 추천할 때 메시지와 함께 제품 카드를 표시
    if (isAI && recommendedProduct != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                size: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI 메시지
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                  SizedBox(height: 8.h),
                  // 제품 카드
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
                        '/product-detail',
                        extra: recommendedProduct!.productId,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  recommendedProduct!.brandName,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  recommendedProduct!.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  recommendationReason ?? '',
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

    // 일반적인 메시지 버블
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment:
            isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAI) ...[
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
          Flexible(
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

  Widget _buildInputArea() {
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8B7AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: textController,
                enabled: !isLoading,
                style: TextStyle(color: const Color(0xFF8B7AFF)),
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF8B7AFF).withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                onSubmitted: onSendMessage,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8B7AFF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed:
                  isLoading ? null : () => onSendMessage(textController.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context) {
    if (recommendedProduct == null) return SizedBox.shrink();

    return SingleChildScrollView(
      // 스크롤 가능하도록 추가
      child: GestureDetector(
        // 카드 전체 클릭 가능하도록 추가
        onTap: () => context.push(
          '/product-detail',
          extra: recommendedProduct!.productId,
        ),
        child: Container(
          margin: EdgeInsets.all(12.w), // 마진 줄임
          constraints: BoxConstraints(
            // 최대 높이 제한
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞추도록 변경
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: Image.network(
                  recommendedProduct!.productImageList.first,
                  width: double.infinity,
                  height: 150.h, // 이미지 높이 줄임
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w), // 패딩 줄임
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendedProduct!.brandName,
                      style: TextStyle(
                        fontSize: 12.sp, // 폰트 크기 줄임
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      recommendedProduct!.name,
                      style: TextStyle(
                        fontSize: 14.sp, // 폰트 크기 줄임
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      recommendationReason ?? '',
                      style: TextStyle(
                        fontSize: 12.sp, // 폰트 크기 줄임
                        color: const Color(0xFF8B7AFF),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push(
                          '/product-detail',
                          extra: recommendedProduct!.productId,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B7AFF),
                          padding:
                              EdgeInsets.symmetric(vertical: 10.h), // 패딩 줄임
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          '자세히 보기',
                          style: TextStyle(
                            fontSize: 14.sp, // 폰트 크기 줄임
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
