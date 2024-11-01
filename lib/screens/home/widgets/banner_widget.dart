import 'dart:async'; // 주기적인 타이머를 위한 Timer 라이브러리 임포트

import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/styles.dart';

import '../../../models/home_model.dart'; // BannerItem 모델을 사용하기 위한 임포트

// 배너 위젯 클래스 정의 (자동 슬라이드 기능 포함)
class BannerWidget extends StatefulWidget {
  final PageController pageController; // 배너의 페이지 전환을 제어하는 컨트롤러
  final List<BannerItem> bannerItems; // 배너에 표시할 데이터 리스트

  const BannerWidget({
    required this.pageController,
    required this.bannerItems,
    super.key,
  });

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  int _currentBanner = 0; // 현재 표시 중인 배너 인덱스
  Timer? _bannerTimer; // 배너 자동 전환 타이머

  @override
  void initState() {
    super.initState();
    _startBannerTimer(); // 초기화 시 배너 타이머 시작
  }

  @override
  void dispose() {
    _bannerTimer?.cancel(); // 위젯 종료 시 타이머 취소
    super.dispose();
  }

  // 배너 자동 전환을 위한 타이머 시작 함수
  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // 타이머가 매 3초마다 호출됨
      if (_currentBanner < widget.bannerItems.length - 1) {
        _currentBanner++; // 다음 배너로 이동
      } else {
        _currentBanner = 0; // 마지막 배너 이후 첫 번째 배너로 이동
      }

      // 페이지 컨트롤러가 클라이언트 연결을 유지하고 있는 경우에만 배너 전환 실행
      if (widget.pageController.hasClients) {
        widget.pageController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 350), // 전환 애니메이션 시간
          curve: Curves.easeInOut, // 전환 애니메이션 곡선
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // 배너 영역 높이
      child: Stack(
        children: [
          // 배너 슬라이드 영역
          PageView.builder(
            controller: widget.pageController, // 전달받은 페이지 컨트롤러
            onPageChanged: (index) {
              // 사용자가 슬라이드를 직접 전환할 때 호출
              setState(() {
                _currentBanner = index; // 현재 배너 인덱스 업데이트
              });
            },
            itemCount: widget.bannerItems.length, // 배너의 총 개수
            itemBuilder: (context, index) {
              return Container(
                color: widget.bannerItems[index].backgroundColor, // 배경 색상 설정
                padding: AppStyles.defaultPadding, // 스타일 패딩 적용
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 배너 제목 텍스트
                    Text(
                      widget.bannerItems[index].title, // 배너 제목
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // 제목과 부제목 사이 간격
                    // 배너 부제목 텍스트
                    Text(
                      widget.bannerItems[index].subtitle, // 배너 부제목
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // 배너 인디케이터 (현재 배너 위치를 나타내는 작은 점들)
          Positioned(
            bottom: 16, // 화면 하단에서의 위치
            right: 16, // 화면 오른쪽에서의 위치
            child: Row(
              children: List.generate(
                widget.bannerItems.length, // 배너의 총 개수만큼 인디케이터 생성
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4), // 점 사이 간격
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // 현재 배너에 해당하는 점만 불투명하게 표시하여 강조
                    color: _currentBanner == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// SliverToBoxAdapter(
// child: BlocBuilder<HomeBloc, HomeState>(
// builder: (context, state) {
// if (state is HomeLoaded) {
// return BannerWidget(
// pageController: _pageController,
// bannerItems: state.bannerItems,
// );
// }
// return SizedBox.shrink();
// },
// ),
// ),
