import 'package:flutter/material.dart';

class OliveYoungHome extends StatefulWidget {
  //^ StatefulWidget으로 변경
  @override
  _OliveYoungHomeState createState() => _OliveYoungHomeState();
}

class _OliveYoungHomeState extends State<OliveYoungHome>
    with SingleTickerProviderStateMixin {
  //^ TabController 추가
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            Icon(Icons.spa, color: Color(0xFF9BCA48)), // 올리브영 로고 대신 아이콘 사용
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
              'Health',
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      // 메인 컨텐츠
      body: Column(
        children: [
          // 상단 탭바
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              //^ Controller 연결
              isScrollable: true,
              tabs: [
                Tab(text: '홈'),
                Tab(text: '딘토'),
                Tab(text: '오톡'),
                Tab(text: '랭킹'),
                Tab(text: '매거진'),
                Tab(text: 'LUXE EDIT'),
              ],
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),

          // 스크롤 가능한 메인 컨텐츠
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 프로모션 배너
                  Container(
                    height: 200,
                    color: Colors.black,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '럭키 럭스에디트\n최대 2만원 혜택',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '쿠폰부터 100% 리워드까지',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 퀵메뉴 그리드
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

                  // 인기상품 섹션
                  _buildProductSection('국한님을 위한 인기상품'),

                  // 최근 본 연관 추천 상품 섹션
                  _buildProductSection('최근 본 연관 추천 상품'),
                ],
              ),
            ),
          ),
        ],
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '카테고리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            label: '서티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '히스토리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '마이',
          ),
        ],
      ),
    );
  }

  // 퀵메뉴 아이템 위젯
  Widget _buildQuickMenuItem(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // 상품 섹션 위젯
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
            itemBuilder: (context, index) => _buildProductCard(),
            itemCount: 5,
          ),
        ),
      ],
    );
  }

  // 상품 카드 위젯
  Widget _buildProductCard() {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지
          Container(
            height: 150,
            child: Center(
              // Center widget 추가
              child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
          ),
          SizedBox(height: 8),
          // 상품명
          Text(
            '[트러블/민감] 아크네스 모공 클리어 젤 클렌저...',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 4),
          // 가격 정보
          Row(
            children: [
              Text(
                '30%',
                style: TextStyle(
                  color: Colors.red,
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
          // 리뷰 정보
          Row(
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber),
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
