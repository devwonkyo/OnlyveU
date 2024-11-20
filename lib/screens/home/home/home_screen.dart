import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/screens/home/ai_recommend/ai_recommend_screen.dart';
import 'package:onlyveyou/screens/home/home/widgets/banner_widget.dart';
import 'package:onlyveyou/screens/home/home/widgets/popular_products_widget.dart';
import 'package:onlyveyou/screens/home/home/widgets/recommended_products_widget.dart';
import 'package:onlyveyou/screens/home/ranking/ranking_tap_screen.dart';
import 'package:onlyveyou/screens/home/todaysale/todaysale_tap_screen.dart';
import 'package:onlyveyou/utils/firebase_data_uploader.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/utils/styles.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late final PageController _pageController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    _pageController = PageController();
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HomeBloc>().add(LoadMoreProducts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(mainColor: AppStyles.mainColor),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHomeTab(),
                  _buildRankingTab(),
                  _buildTodaySaleTab(),
                  _buildMagazineTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1.w),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        isScrollable: true,
        padding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
        tabs: [
          Tab(text: '홈'),
          Tab(text: '랭킹'),
          Tab(text: '오특'),
          Tab(text: 'AI추천'),
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

  // 홈 탭 컨텐츠
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) =>
                    current is HomeLoaded || current is HomeLoading,
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is HomeLoaded) {
                    return BannerWidget(
                      pageController: _pageController,
                      bannerItems: state.bannerItems,
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildQuickMenu(
              MediaQuery.of(context).orientation == Orientation.portrait,
            ),
          ),
          _buildRecommendedProducts(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: InkWell(
                onTap: () => print("쿠폰 눌림"),
                child: Image.asset(
                  'assets/image/banner4.png',
                  width: MediaQuery.of(context).size.width * 0.95,
                ),
              ),
            ),
          ),
          _buildPopularProducts(),
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  // 랭킹 탭 컨텐츠
  Widget _buildRankingTab() {
    return RankingTabScreen();
  }

  Widget _buildTodaySaleTab() {
    return TodaySaleTabScreen();
  }

  // 나중에 탭 컨텐츠
  Widget _buildMagazineTab() {
    return AIRecommendScreen();
  }

  // 기존 위젯들...
  Widget _buildQuickMenu(bool isPortrait) {
    // 기존 코드 유지
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: isPortrait ? 5 : 8,
      mainAxisSpacing: 8.h,
      crossAxisSpacing: 8.w,
      childAspectRatio: isPortrait ? 1 : 1.2,
      padding: AppStyles.defaultPadding,
      children: [
        _buildQuickMenuItem('AI원픽', Icons.favorite, () {
          context.push('/ai-onepick'); // ResetChat 제거
        }),
        _buildQuickMenuItem('날씨추천', Icons.wb_sunny_sharp, () {
          context.push('/weather');
        }),
        _buildQuickMenuItem('AR가상', Icons.live_tv, () {
          context.push('/virtual');
        }), // _uploadDummyData(context);
        _buildQuickMenuItem('VS투표', Icons.balance_rounded, () {
          context.push('/debate');
        }),
        _buildQuickMenuItem('운세', Icons.hail_outlined, () {
          context.push('/mbti');
        }),
      ],
    );
  }

  Widget _buildQuickMenuItem(String label, IconData icon, VoidCallback onTap) {
    // 기존 코드 유지
    bool isUploading = _isUploading && label == '뭐할까';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32.w, color: AppStyles.mainColor),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppStyles.smallTextStyle,
              textAlign: TextAlign.center,
            ),
            if (isUploading)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppStyles.mainColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadDummyData(BuildContext context) async {
    // 기존 코드 유지
    if (_isUploading) return;

    try {
      setState(() {
        _isUploading = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('더미데이터 업로드 중...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final uploader = FirebaseDataUploader();
      await uploader.initializeDatabase();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('더미데이터 업로드 완료!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('업로드 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildRecommendedProducts() {
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            return FutureBuilder<String>(
              future: OnlyYouSharedPreference().getCurrentUserId(),
              builder: (context, snapshot) {
                return RecommendedProductsWidget(
                  recommendedProducts: state.recommendedProducts,
                  isPortrait: MediaQuery.of(context).orientation ==
                      Orientation.portrait,
                  userId: snapshot.data ?? 'temp_user_id',
                );
              },
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPopularProducts() {
    return SliverToBoxAdapter(
      child: BlocSelector<HomeBloc, HomeState, List<ProductModel>>(
        selector: (state) => state is HomeLoaded ? state.popularProducts : [],
        builder: (context, products) {
          return products.isEmpty
              ? Center(child: CircularProgressIndicator())
              : PopularProductsWidget(
                  popularProducts: products,
                  isPortrait: MediaQuery.of(context).orientation ==
                      Orientation.portrait,
                );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return BlocSelector<HomeBloc, HomeState, bool>(
      selector: (state) => state is HomeLoaded && state.isLoading,
      builder: (context, isLoading) {
        return SliverToBoxAdapter(
          child: isLoading
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.h),
                    child: CircularProgressIndicator(),
                  ),
                )
              : SizedBox.shrink(),
        );
      },
    );
  }
}
