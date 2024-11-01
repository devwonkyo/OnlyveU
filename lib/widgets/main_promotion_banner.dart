// 메인 프로모션 배너 위젯
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainPromotionBanner extends StatefulWidget {
  const MainPromotionBanner({Key? key}) : super(key: key);

  @override
  State<MainPromotionBanner> createState() => _MainPromotionBannerState();
}

class _MainPromotionBannerState extends State<MainPromotionBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, String>> promotions = [
    {
      'image': 'assets/image/skin2.webp',
      'title': '고민별 기초케어로\n집중타켓',
      'subtitle': '#11월 올영픽',
    },
    {
      'image': 'assets/image/skin2.webp',
      'title': '고민별 기초케어로\n집중타켓',
      'subtitle': '#11월 올영픽',
    },
    {
      'image': 'assets/image/skin2.webp',
      'title': '고민별 기초케어로\n집중타켓',
      'subtitle': '#11월 올영픽',
    },
    // 추가 프로모션 항목...
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < promotions.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 200.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              return Container(
                child: Image.asset(
                  promotions[index]['image']!,
                  fit: BoxFit.fill,
                ),
              );
            },
          ),
        ),
        // 페이지 인디케이터와 컨트롤
        Positioned(
          bottom: 16.h,
          right: 32.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '${_currentPage + 1} / ${promotions.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}