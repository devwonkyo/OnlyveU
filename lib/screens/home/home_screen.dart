//홈화면이 라우터 설정 애니메이션 효과
//바텀 네비게이션바 기능 살리기

//스크린 유틸
//위젯 분리
//블록에 맞춰서 하기
//코드 다듬기
//이제 스크린 유틸 하기

//데이터를 리스트로 가져와서 리스트 뷰로 스크롤되도록
// 하나하나 띄어올수 있게 바꾸기

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/screens/home/widgets/banner_widget.dart';
import 'package:onlyveyou/screens/home/widgets/popular_products_widget.dart';
import 'package:onlyveyou/screens/home/widgets/recommended_products_widget.dart';
import 'package:onlyveyou/utils/device_preview_widget.dart';
import 'package:onlyveyou/utils/screen_util.dart';
import 'package:onlyveyou/utils/styles.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';

// 홈 화면 위젯 정의
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController; // 탭 컨트롤러 초기화
  final PageController _pageController = PageController(); // 배너 페이지 전환용 컨트롤러

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 6, vsync: this); // 6개의 탭을 컨트롤하는 탭 컨트롤러 생성
    context.read<HomeBloc>().add(LoadHomeData()); // 홈 데이터 로드 이벤트 전송
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait =
                orientation == Orientation.portrait; // 세로 모드 여부 확인

            if (state is HomeLoading) {
              // 데이터 로딩 중일 때 로딩 표시
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is HomeError) {
              // 데이터 로드 오류 시 에러 메시지 표시
              return Scaffold(
                body: Center(child: Text(state.message)),
              );
            }

            if (state is HomeLoaded) {
              // 데이터 로드 성공 시 홈 화면 구성
              return Scaffold(
                backgroundColor: Colors.white,
                appBar:
                    DefaultAppBar(mainColor: AppStyles.mainColor), // 커스텀 앱바 사용
                body: SafeArea(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _buildTabBar(), // 탭 바 생성
                          Expanded(
                            child: RefreshIndicator(
                              // 새로고침 기능 추가
                              onRefresh: () async {
                                context
                                    .read<HomeBloc>()
                                    .add(RefreshHomeData()); // 새로고침 이벤트 발생
                              },
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    BannerWidget(
                                      pageController: _pageController,
                                      bannerItems:
                                          state.bannerItems, // 배너 데이터 전달
                                    ),
                                    _buildQuickMenu(isPortrait), // 퀵 메뉴 생성
                                    RecommendedProductsWidget(
                                      recommendedProducts:
                                          state.recommendedProducts,
                                      isPortrait: isPortrait,
                                    ), // 추천 상품 위젯
                                    PopularProductsWidget(
                                      popularProducts: state.popularProducts,
                                      isPortrait: isPortrait,
                                    ), // 인기 상품 위젯
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (kDebugMode) // 디버그 모드에서만 스크린 유틸 확인용 위젯 표시
                        Positioned(
                          top: ScreenUtil.safeAreaTop + 60.h,
                          right: 16.w,
                          child: DevicePreviewWidget(),
                        ),
                    ],
                  ),
                ),
              );
            }

            return Container(); // 기본 상태 시 빈 화면 반환
          },
        );
      },
    );
  }

  // 탭 바 위젯
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom:
              BorderSide(color: Colors.grey[300]!, width: 1.w), // 탭 바 하단의 구분선
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true, // 탭을 스크롤 가능하게 설정
        tabs: [
          Tab(text: '홈'),
          Tab(text: '딘토'),
          Tab(text: '오톡'),
          Tab(text: '랭킹'),
          Tab(text: '매거진'),
          Tab(text: 'LUXE EDIT'),
        ],
        labelColor: AppStyles.mainColor, // 선택된 탭의 텍스트 색상
        unselectedLabelColor: AppStyles.greyColor, // 선택되지 않은 탭의 텍스트 색상
        indicatorColor: AppStyles.mainColor, // 선택된 탭 하단 인디케이터 색상
        indicatorSize: TabBarIndicatorSize.label, // 인디케이터 크기를 탭 레이블 크기에 맞춤
        labelStyle: AppStyles.subHeadingStyle, // 선택된 탭의 텍스트 스타일
        unselectedLabelStyle: AppStyles.bodyTextStyle, // 선택되지 않은 탭의 텍스트 스타일
      ),
    );
  }

  // 퀵 메뉴 위젯
  Widget _buildQuickMenu(bool isPortrait) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // 스크롤 금지
      crossAxisCount: isPortrait ? 5 : 8, // 세로 모드에서는 5열, 가로 모드에서는 8열
      mainAxisSpacing: 8.h,
      crossAxisSpacing: 8.w,
      childAspectRatio: isPortrait ? 1 : 1.2, // 세로/가로 모드에 따른 아이템 비율 조정
      padding: AppStyles.defaultPadding,
      children: [
        _buildQuickMenuItem('W케어', Icons.favorite),
        _buildQuickMenuItem('건강템찾기', Icons.medication),
        _buildQuickMenuItem('라이브', Icons.live_tv),
        _buildQuickMenuItem('선물하기', Icons.card_giftcard),
        _buildQuickMenuItem('세일', Icons.local_offer),
      ],
    );
  }

  // 퀵 메뉴 아이템 위젯 (아이콘과 레이블로 구성)
  Widget _buildQuickMenuItem(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32.w, color: AppStyles.mainColor), // 아이콘
        SizedBox(height: 4.h),
        Text(label, style: AppStyles.smallTextStyle), // 레이블 텍스트
      ],
    );
  }
}
