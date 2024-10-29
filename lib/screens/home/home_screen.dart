//홈화면이 라우터 설정 애니메이션 효과
//바텀 네비게이션바 기능 살리기

//스크린 유틸
//위젯 분리
//블록에 맞춰서 하기
//코드 다듬기

//이제 스크린 유틸 하기

import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/screen_util.dart';
import '../../utils/styles.dart';
import '../../widgets/default_appbar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color mainColor = AppStyles.mainColor;

  // 배너 관련 변수 추가
  final PageController _pageController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  // 클래스 상단에 상품 이미지 리스트 추가
  final List<String> _productImages = [
    'assets/image/banner3.png',
    'assets/image/skin2.webp',
    'assets/image/skin3.webp',
    'assets/image/skin4.webp',
  ];

  final List<BannerItem> _bannerItems = [
    BannerItem(
      title: '럭키 럭스에디트\n최대 2만원 혜택',
      subtitle: '쿠폰부터 100% 리워드까지',
      backgroundColor: Colors.black,
    ),
    BannerItem(
      title: '가을 준비하기\n최대 50% 할인',
      subtitle: '시즌 프리뷰 특가전',
      backgroundColor: Color(0xFF8B4513),
    ),
    BannerItem(
      title: '이달의 브랜드\n특별 기획전',
      subtitle: '인기 브랜드 혜택 모음',
      backgroundColor: Color(0xFF4A90E2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _startBannerTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentBanner < _bannerItems.length - 1) {
        _currentBanner++;
      } else {
        _currentBanner = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBanner,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        // 가로/세로 모드에 따른 값 조정
        final isPortrait = orientation == Orientation.portrait;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: DefaultAppBar(mainColor: mainColor),
          body: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1.w),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: [
                    Tab(text: '홈'),
                    Tab(text: '딘토'),
                    Tab(text: '오톡'),
                    Tab(text: '랭킹'),
                    Tab(text: '매거진'),
                    Tab(text: 'LUXE EDIT'),
                  ],
                  labelColor: mainColor,
                  unselectedLabelColor: AppStyles.greyColor,
                  indicatorColor: mainColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: AppStyles.subHeadingStyle,
                  unselectedLabelStyle: AppStyles.bodyTextStyle,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 배너 섹션
                      Container(
                        height: 200.h,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentBanner = index;
                                });
                              },
                              itemCount: _bannerItems.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  color: _bannerItems[index].backgroundColor,
                                  padding: AppStyles.defaultPadding,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _bannerItems[index].title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        _bannerItems[index].subtitle,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 16.h,
                              right: 16.w,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  _bannerItems.length,
                                  (index) => Container(
                                    width: 8.w,
                                    height: 8.w,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.w),
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
                      ),

                      // 퀵 메뉴 섹션
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 5,
                        padding: AppStyles.defaultPadding,
                        children: [
                          _buildQuickMenuItem('W케어', Icons.favorite),
                          _buildQuickMenuItem('건강템찾기', Icons.medication),
                          _buildQuickMenuItem('라이브', Icons.live_tv),
                          _buildQuickMenuItem('선물하기', Icons.card_giftcard),
                          _buildQuickMenuItem('세일', Icons.local_offer),
                        ],
                      ),

                      // 상품 섹션
                      _buildProductSection('국한님을 위한 추천상품'),
                      _buildProductSection('최근 본 연관 인기 상품'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickMenuItem(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32.w, color: mainColor),
        SizedBox(height: 4.h),
        Text(label, style: AppStyles.smallTextStyle),
      ],
    );
  }

  Widget _buildProductSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppStyles.defaultPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppStyles.headingStyle),
              Text('더보기 >',
                  style: AppStyles.bodyTextStyle
                      .copyWith(color: AppStyles.greyColor)),
            ],
          ),
        ),
        SizedBox(
          height: 320.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: AppStyles.horizontalPadding,
            itemBuilder: (context, index) => _buildProductCard(index),
            itemCount: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(int index) {
    return Container(
      width: AppStyles.productCardWidth,
      margin: EdgeInsets.only(right: AppStyles.productCardSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: AppStyles.productCardHeight,
            child: ClipRRect(
              borderRadius: AppStyles.defaultRadius,
              child: Image.asset(
                _productImages[index % _productImages.length],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    color: Colors.grey[200],
                    child:
                        Icon(Icons.image, size: 120.w, color: Colors.grey[400]),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '[트러블/민감] 아크네스 모공 클리어 젤 클렌저...',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodyTextStyle,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text('30%', style: AppStyles.discountTextStyle),
              SizedBox(width: 4.w),
              Text('12,600원', style: AppStyles.priceTextStyle),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.star, size: 14.w, color: mainColor),
              Text('4.8 (1,234)', style: AppStyles.smallTextStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class BannerItem {
  final String title;
  final String subtitle;
  final Color backgroundColor;

  BannerItem({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
  });
}
