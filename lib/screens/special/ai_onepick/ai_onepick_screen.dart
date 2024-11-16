import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/special_bloc/ai_onepick_bloc.dart';
import 'package:onlyveyou/repositories/special/ai_onepick_repository.dart';
import 'package:onlyveyou/screens/special/ai_onepick/widgets/onepick_chat_area_widget.dart';
import 'package:onlyveyou/screens/special/ai_onepick/widgets/onepick_header_widget.dart';

class AIOnepickScreen extends StatefulWidget {
  const AIOnepickScreen({Key? key}) : super(key: key);

  @override
  State<AIOnepickScreen> createState() => _AIOnepickScreenState();
}

class _AIOnepickScreenState extends State<AIOnepickScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 대화 시작
    context.read<AIOnepickBloc>().add(StartChat());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _controller.clear();
    context.read<AIOnepickBloc>().add(SendMessage(text));
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
      appBar: _buildAppBar(),
      body: BlocConsumer<AIOnepickBloc, AIOnepickState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }

          if (state is AIOnepickComplete) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          return Container(
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
                SizedBox(height: MediaQuery.of(context).padding.top),
                // AIChatHeader를 상단으로 이동
                AIChatHeader(
                  currentStep: context.read<AIOnepickRepository>().currentStep,
                ),
                Expanded(
                  child: AIChatContent(
                    messages: context.read<AIOnepickRepository>().chatHistory,
                    scrollController: _scrollController,
                    textController: _controller,
                    onSendMessage: _handleSubmitted,
                    isLoading: state.isLoading,
                    recommendedProduct:
                        state is AIOnepickComplete ? state.product : null,
                    recommendationReason: state is AIOnepickComplete
                        ? state.recommendationReason
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
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
          onPressed: () => context.read<AIOnepickBloc>().add(ResetChat()),
        ),
        SizedBox(width: 8.w),
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
