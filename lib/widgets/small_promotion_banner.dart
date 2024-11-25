// 작은 프로모션 배너 위젯
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SmallPromotionBanner extends StatefulWidget {
  final List<Map<String, String>> promotions;

  const SmallPromotionBanner({Key? key, required this.promotions}) : super(key: key);

  @override
  State<SmallPromotionBanner> createState() => _SmallPromotionBannerState();
}

class _SmallPromotionBannerState extends State<SmallPromotionBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  late final List<Map<String, String>> promotions;


  @override
  void initState() {
    super.initState();
    promotions = widget.promotions;

    if(promotions.length > 2){
      _startAutoScroll();
    }
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
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 70.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    promotions[index]['image']!,
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        // 도트 인디케이터
        if(promotions.length > 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            promotions.length,
                (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Colors.black
                    : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
