import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widgets/onepick_chat_area_widget.dart';
import 'widgets/onepick_header_widget.dart';

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

  void _resetChat() {
    setState(() {
      _messages.clear();
      currentStep = 0;
      _messages.add(ChatMessage(text: aiMessages[0], isAI: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
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
            AIChatHeader(currentStep: currentStep),
            Expanded(
              child: AIChatContent(
                messages: _messages,
                scrollController: _scrollController,
                textController: _controller,
                onSendMessage: _handleUserResponse,
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
          onPressed: _resetChat,
        ),
        SizedBox(width: 8.w),
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
