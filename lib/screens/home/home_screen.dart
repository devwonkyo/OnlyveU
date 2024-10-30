import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/screens/home/widgets/popular_products_widget.dart';
import 'package:onlyveyou/screens/home/widgets/recommended_products_widget.dart';
import 'package:onlyveyou/utils/styles.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(mainColor: AppStyles.mainColor), // 커스텀 앱바 사용
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  //배너
                  child: _buildTabBar(), // 상단에 고정되는 탭 바
                ),
                // 배너 돌다보면 앱 느려짐 평소엔 주석해둘것
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
                SliverToBoxAdapter(
                  child: _buildQuickMenu(MediaQuery.of(context).orientation ==
                      Orientation.portrait),
                ),
                SliverToBoxAdapter(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) =>
                        current is HomeLoaded || current is HomeLoading,
                    builder: (context, state) {
                      if (state is HomeLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is HomeLoaded) {
                        // RecommendedProductsWidget이 이제 List<HistoryItem>을 받도록 변경됨
                        return RecommendedProductsWidget(
                          recommendedProducts:
                              state.recommendedProducts, // List<HistoryItem> 타입
                          isPortrait: MediaQuery.of(context).orientation ==
                              Orientation.portrait,
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),

                SliverToBoxAdapter(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) =>
                        current is HomeLoaded || current is HomeLoading,
                    builder: (context, state) {
                      if (state is HomeLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is HomeLoaded) {
                        // PopularProductsWidget도 List<HistoryItem>을 받도록 변경됨
                        return PopularProductsWidget(
                          popularProducts:
                              state.popularProducts, // List<HistoryItem> 타입
                          isPortrait: MediaQuery.of(context).orientation ==
                              Orientation.portrait,
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
///////////////////////
// Container(
// height: 8,
// color: const Color.fromARGB(195, 232, 227, 227),
// ),
// const SizedBox(
// height: 20,
// ),
// Center(
// child: SizedBox(
// width: MediaQuery.of(context).size.width * 0.95, // 이미지 크기 설정
// child: InkWell(
// onTap: () {
// print("쿠폰 눌림");
// },
// child: Image.asset(
// 'assets/image/mypage/coupon_image.jpeg', //네트워크 이미지
// ),
// ),
// ),
// ),
// const SizedBox(
// height: 20,
// ),
