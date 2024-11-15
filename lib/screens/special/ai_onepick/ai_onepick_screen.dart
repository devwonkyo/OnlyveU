import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatMessage {
  final String text;
  final bool isAI;

  ChatMessage({required this.text, required this.isAI});
}

List<String> aiMessages = [
  "안녕하세요! 오늘 고객님께 가장 잘 맞는 화장품을 찾아드리기 위해 몇 가지 여쭤보겠습니다. 먼저, 평소 피부 타입이 어떻게 되시나요?",
  "피부 고민이 있다면 무엇인가요?",
  "선호하시는 제형이 있으신가요? (크림/에센스/로션 등)",
  "평소 사용하시는 화장품 중 만족스러웠던 제품이 있다면 어떤 점이 좋으셨나요?",
  "마지막으로, 가격대는 어느 정도로 생각하고 계신가요?",
];

class AIOnepickScreen extends StatefulWidget {
  const AIOnepickScreen({Key? key}) : super(key: key);

  @override
  State<AIOnepickScreen> createState() => _AIOnepickScreenState();
}

class _AIOnepickScreenState extends State<AIOnepickScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.add(ChatMessage(text: aiMessages[0], isAI: true));
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleUserResponse(String message) {
    setState(() {
      _messages.add(ChatMessage(text: message, isAI: false));

      if (currentStep < 4) {
        currentStep++;
        _messages.add(ChatMessage(text: aiMessages[currentStep], isAI: true));
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            SizedBox(width: 12.w),
            Text(
              'AI OnePick',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              setState(() {
                _messages.clear();
                currentStep = 0;
                _messages.add(ChatMessage(text: aiMessages[0], isAI: true));
              });
            },
          ),
          SizedBox(width: 8.w),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0E6FF),
              Color(0xFFFFFBFF),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top),
            _buildProgressIndicator(),
            _buildHeader(),
            Expanded(
              child: _buildChatArea(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
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

  Widget _buildHeader() {
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

  Widget _buildChatArea() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white, // 위는 불투명
            Colors.transparent, // 그 아래는 투명
            Colors.transparent, // 계속 투명
          ],
          stops: [
            0.0,
            0.1,
            0.7,
          ], // 투명도가 변화하는 위치를 세밀하게 설정
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstOut,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          return _buildMessageBubble(_messages[index]);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
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
                controller: _controller,
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
                if (_controller.text.isNotEmpty) {
                  _handleUserResponse(_controller.text);
                  _controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
