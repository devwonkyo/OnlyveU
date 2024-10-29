//홈화면이 라우터 설정 애니메이션 효과
//바텀 네비게이션바 기능 살리기
//스크린 유틸
//위젯 분리
//블록에 맞춰서 하기
//코드 다듬기

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color mainColor = Color(0xFFC9C138);

  // 배너 관련 변수 추가
  final PageController _pageController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  // 클래스 상단에 상품 이미지 리스트 추가
  final List<String> _productImages = [
    'assets/image/banner3.png', // 원하는 이미지로 변경
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
    return Scaffold(
      backgroundColor: Colors.white,
      // 앱바
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.spa, color: mainColor),
            const SizedBox(width: 8),
            const Text(
              '온니브유',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Onlyveyou',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              context.push('/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
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
              unselectedLabelColor: Colors.grey,
              indicatorColor: mainColor,
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 200,
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
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _bannerItems[index].title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _bannerItems[index].subtitle,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              _bannerItems.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4),
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
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 5,
                    padding: EdgeInsets.all(16),
                    children: [
                      _buildQuickMenuItem('W케어', Icons.favorite),
                      _buildQuickMenuItem('건강템찾기', Icons.medication),
                      _buildQuickMenuItem('라이브', Icons.live_tv),
                      _buildQuickMenuItem('선물하기', Icons.card_giftcard),
                      _buildQuickMenuItem('세일', Icons.local_offer),
                    ],
                  ),
                  _buildProductSection('국한님을 위한 추천상품'),
                  _buildProductSection('최근 본 연관 인기 상품'),
                ],
              ),
            ),
          ),
        ],
      ),

      //^ 분리한 위젯 사용
    );
  }

  Widget _buildQuickMenuItem(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: mainColor),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProductSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '더보기 >',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) =>
                _buildProductCard(index), // index 전달
            itemCount: 4,
          ),
        ),
      ],
    );
  }

// _buildProductCard 메서드 수정
  Widget _buildProductCard(int index) {
    // index 매개변수 추가
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            child: ClipRRect(
              // 이미지에 borderRadius 적용을 위해 ClipRRect 사용
              borderRadius: BorderRadius.circular(8),

              child: Image.asset(
                _productImages[index % _productImages.length], // 여기에 원하는 이미지 경로
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    color: Colors.grey[200],
                    child:
                        Icon(Icons.image, size: 120, color: Colors.grey[400]),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '[트러블/민감] 아크네스 모공 클리어 젤 클렌저...',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                '30%',
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '12,600원',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star, size: 14, color: mainColor),
              Text(
                '4.8 (1,234)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
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
