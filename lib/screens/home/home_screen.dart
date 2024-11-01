import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/screens/home/widgets/popular_products_widget.dart';
import 'package:onlyveyou/screens/home/widgets/recommended_products_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _scrollController.addListener(_onScroll);
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
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
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(RefreshHomeData());
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildQuickMenu(
                        MediaQuery.of(context).orientation ==
                            Orientation.portrait,
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
        isScrollable: true,
        padding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
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

  Widget _buildRecommendedProducts() {
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is HomeLoaded) {
            return RecommendedProductsWidget(
              recommendedProducts:
                  state.recommendedProducts, // ProductModel로 수정
              isPortrait:
                  MediaQuery.of(context).orientation == Orientation.portrait,
              userId: "userId_here", // userId 전달, 실제 로그인 구현 시 사용자 ID로 대체
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
