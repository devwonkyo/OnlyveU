import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/screens/special/ai_onepick/ai_onepick_screen.dart';

class AIChatContent extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final TextEditingController textController;
  final Function(String) onSendMessage;

  const AIChatContent({
    Key? key,
    required this.messages,
    required this.scrollController,
    required this.textController,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _buildChatArea(),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildChatArea() {
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
          return _buildMessageBubble(messages[index], context);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment:
            message.isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.isAI) ...[
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
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: message.isAI
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
              message.text,
              style: TextStyle(
                color: message.isAI ? const Color(0xFF8B7AFF) : Colors.white,
                fontSize: 14.sp,
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
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  onSendMessage(textController.text);
                  textController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
