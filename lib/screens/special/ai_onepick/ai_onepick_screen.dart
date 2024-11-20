import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/special_bloc/ai_onepick_bloc.dart';
import 'package:onlyveyou/repositories/special/ai_onepick_repository.dart';
import 'package:onlyveyou/screens/special/ai_onepick/widgets/onepick_chat_area_widget.dart';
import 'package:onlyveyou/screens/special/ai_onepick/widgets/onepick_header_widget.dart';

//
// AIOnepickScreen은 AI와 대화를 처리하는 화면입니다.
class AIOnepickScreen extends StatefulWidget {
  const AIOnepickScreen({Key? key}) : super(key: key);

  @override
  State<AIOnepickScreen> createState() => _AIOnepickScreenState();
}

class _AIOnepickScreenState extends State<AIOnepickScreen> {
  // 사용자 입력을 관리하기 위한 TextEditingController
  final TextEditingController _controller = TextEditingController();
  // 메시지 목록을 스크롤하기 위한 ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 의존성이 변경될 때 호출됨
    // Bloc을 통해 채팅 상태를 초기화
    context.read<AIOnepickBloc>().add(
        ResetChat()); // ResetChat -> StartChat -> repository.startChat() 호출 순서
  }

  @override
  void initState() {
    super.initState();
    // 추가 초기화 작업이 필요한 경우 여기에 작성
    // 예: UI 요소 초기화, 상태 설정 등
  }

  @override
  void dispose() {
    // 컨트롤러를 명시적으로 dispose하여 메모리 누수 방지
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 메시지 제출 처리
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return; // 빈 입력값 무시

    _controller.clear(); // 입력 필드 초기화
    context.read<AIOnepickBloc>().add(SendMessage(text)); // Bloc에 메시지 이벤트 전달
    _scrollToBottom(); // 메시지 입력 후 화면 하단으로 스크롤
  }

  // 스크롤을 화면 하단으로 이동
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // 가장 하단으로 이동
        duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
        curve: Curves.easeOut, // 스크롤 애니메이션 곡선
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Body를 AppBar 뒤로 확장
      appBar: _buildAppBar(), // 커스텀 AppBar 위젯
      body: BlocConsumer<AIOnepickBloc, AIOnepickState>(
        listener: (context, state) {
          // 상태 변화 감지 리스너
          if (state.errorMessage != null) {
            // 에러 메시지가 있는 경우
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage!)), // 에러 메시지를 SnackBar로 표시
            );
          }

          if (state is AIOnepickComplete) {
            // 채팅이 완료된 경우 화면 하단으로 스크롤
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          // UI 빌드
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF0E6FF), // 상단 색상
                  Color(0xFFFFFBFF), // 하단 색상
                ],
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                    height:
                        MediaQuery.of(context).padding.top), // 상단 패딩 크기만큼 여백 추가
                // AIChatHeader 위젯 - 채팅 헤더를 표시
                AIChatHeader(
                  currentStep: context
                      .read<AIOnepickRepository>()
                      .currentStep, // 현재 단계 정보
                ),
                Expanded(
                  // 채팅 메시지 영역
                  child: AIChatContent(
                    messages: context
                        .read<AIOnepickRepository>()
                        .chatHistory, // 채팅 기록
                    scrollController: _scrollController, // 스크롤 컨트롤러
                    textController: _controller, // 텍스트 입력 컨트롤러
                    onSendMessage: _handleSubmitted, // 메시지 전송 핸들러
                    isLoading: state.isLoading, // 로딩 상태 여부
                    recommendedProduct: state is AIOnepickComplete
                        ? state.product // 추천 상품 정보
                        : null,
                    recommendationReason: state is AIOnepickComplete
                        ? state.recommendationReason // 추천 이유
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

  // 커스텀 AppBar를 빌드하는 메서드
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white), // 뒤로 가기 아이콘
        onPressed: () => context.pop(), // 뒤로 가기 동작
      ),
      title: Row(
        children: [
          SizedBox(width: 12.w), // 간격 조정
          Text(
            'AI OnePick', // 제목 텍스트
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp, // ScreenUtil을 이용한 반응형 폰트 크기
              fontWeight: FontWeight.bold, // 굵은 텍스트
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: Colors.white), // 새로고침 아이콘
          onPressed: () =>
              context.read<AIOnepickBloc>().add(ResetChat()), // 새로고침 동작
        ),
        SizedBox(width: 8.w), // 간격 조정
      ],
      backgroundColor: Colors.transparent, // 투명 배경색
      elevation: 0, // 그림자 제거
    );
  }
}
