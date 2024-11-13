import 'dart:async'; // 주기적인 타이머를 위한 Timer 라이브러리 임포트

import 'package:flutter/material.dart';
import 'package:onlyveyou/models/home_model.dart';

// BannerItem 모델을 사용하기 위한 임포트

// 배너 위젯 클래스 정의 (자동 슬라이드 기능 포함)
class BannerWidget extends StatefulWidget {
  final PageController pageController;
  final List<BannerItem> bannerItems;

  const BannerWidget({
    required this.pageController,
    required this.bannerItems,
    super.key,
  });

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  int _currentBanner = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentBanner < widget.bannerItems.length - 1) {
        _currentBanner++;
      } else {
        _currentBanner = 0;
      }

      if (widget.pageController.hasClients) {
        widget.pageController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 315,
      child: Stack(
        children: [
          PageView.builder(
            controller: widget.pageController,
            onPageChanged: (index) {
              setState(() {
                _currentBanner = index;
              });
            },
            itemCount: widget.bannerItems.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // 이미지
                  Image.asset(
                    widget.bannerItems[index].imageAsset,
                    width: double.infinity,
                    height: 315,
                    fit: BoxFit.cover,
                  ),
                  // 텍스트 오버레이
                  Positioned(
                    bottom: 40,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bannerItems[index].title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.bannerItems[index].subtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // 인디케이터
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              children: List.generate(
                widget.bannerItems.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
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
//   child: BlocBuilder<HomeBloc, HomeState>(
//     buildWhen: (previous, current) =>
//         current is HomeLoaded || current is HomeLoading,
//     builder: (context, state) {
//       if (state is HomeLoading) {
//         return Center(child: CircularProgressIndicator());
//       } else if (state is HomeLoaded) {
//         return BannerWidget(
//           pageController: _pageController,
//           bannerItems: state.bannerItems,
//         );
//       }
//       return SizedBox.shrink();
//     },
//   ),
// ),
