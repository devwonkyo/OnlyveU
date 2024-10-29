//홈화면이 라우터 설정 애니메이션 효과
//바텀 네비게이션바 기능 살리기
//스크린 유틸
//위젯 분리
//블록에 맞춰서 하기
//코드 다듬기
//이제 스크린 유틸 하기

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

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    // HomeBloc 이벤트 발생
    context.read<HomeBloc>().add(LoadHomeData()); //^
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
      //^ BlocProvider 제거하고 BlocBuilder만 사용
      builder: (context, state) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;

            if (state is HomeLoading) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is HomeError) {
              return Scaffold(
                body: Center(child: Text(state.message)),
              );
            }

            if (state is HomeLoaded) {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: DefaultAppBar(mainColor: AppStyles.mainColor),
                body: SafeArea(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _buildTabBar(),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                context
                                    .read<HomeBloc>()
                                    .add(RefreshHomeData()); //^
                              },
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    BannerWidget(
                                      pageController: _pageController,
                                      bannerItems: state.bannerItems,
                                    ),
                                    _buildQuickMenu(isPortrait),
                                    RecommendedProductsWidget(
                                      recommendedProducts:
                                          state.recommendedProducts,
                                      isPortrait: isPortrait,
                                    ),
                                    PopularProductsWidget(
                                      popularProducts: state.popularProducts,
                                      isPortrait: isPortrait,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (kDebugMode)
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

            return Container(); // 기본 상태
          },
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
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
        labelColor: AppStyles.mainColor,
        unselectedLabelColor: AppStyles.greyColor,
        indicatorColor: AppStyles.mainColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: AppStyles.subHeadingStyle,
        unselectedLabelStyle: AppStyles.bodyTextStyle,
      ),
    );
  }

  Widget _buildQuickMenu(bool isPortrait) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: isPortrait ? 5 : 8,
      mainAxisSpacing: 8.h,
      crossAxisSpacing: 8.w,
      childAspectRatio: isPortrait ? 1 : 1.2,
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

  Widget _buildQuickMenuItem(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32.w, color: AppStyles.mainColor),
        SizedBox(height: 4.h),
        Text(label, style: AppStyles.smallTextStyle),
      ],
    );
  }
}
