import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/product/cart/product_cart_bloc.dart';
import 'package:onlyveyou/blocs/product/productdetail_bloc.dart';
import 'package:onlyveyou/blocs/review/review_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/core/router.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/screens/Product/widgets/explain_product.dart';
import 'package:onlyveyou/screens/Product/widgets/product_description_tab.dart';
import 'package:onlyveyou/screens/Product/widgets/review_summary_widget.dart';
import 'package:onlyveyou/screens/Product/widgets/reviewlist_widget.dart';
import 'package:onlyveyou/screens/Product/widgets/sticky_tabbar_delegate.dart';
import 'package:onlyveyou/screens/product/widgets/expandable_bottom_sheet.dart';
import 'package:onlyveyou/utils/deeplink_service.dart';
import 'package:onlyveyou/utils/dummy_data.dart';
import 'package:onlyveyou/utils/format_price.dart';
import 'package:onlyveyou/utils/kakao_share_service.dart';
import 'package:onlyveyou/widgets/small_promotion_banner.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ScrollController _scrollController;
  bool _isAppBarVisible = true;
  late PageController _pageController;
  int _currentPage = 0;
  final KakaoShareService _kakaoShareService = KakaoShareService();



  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    context.read<ProductDetailBloc>().add(LoadProductDetail(widget.productId));
    context.read<ProductDetailBloc>().add(InputProductHistoryEvent(widget.productId));
    context.read<ReviewBloc>().add(LoadReviewListEvent(widget.productId));
    print('productId : ${widget.productId}');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isAppBarVisible) setState(() => _isAppBarVisible = false);
    }
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isAppBarVisible) setState(() => _isAppBarVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<ProductCartBloc, ProductCartState>(
              listener: (context, state) {
                if (state is AddCartSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }

                if (state is AddCartError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
            ),
            BlocListener<ProductDetailBloc, ProductDetailState>(
              listener: (context, state) {
                if (state is ProductLikedSuccess) {
                  if (state.likeState) {
                    //좋아요 를 눌렀을 때
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("좋아요를 눌렀습니다.")),
                    );
                  }
                }
              },
            ),
          ],
          child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
            builder: (context, state) {
              if (state is ProductDetailLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is ProductDetailLoaded) {
                return DefaultTabController(
                  length: 2,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 100.h),
                        child: NestedScrollView(
                          headerSliverBuilder: (context, innerBoxIsScrolled) {
                            return [
                              _buildAppBar(),
                              _buildProductHeader(state.product, state.userId),
                              _buildTabBar(),
                            ];
                          },
                          body: _buildTabBarView(state.product, state.userId),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0, //껏다키면 해결됨
                          child: ExpandableBottomSheet(
                              productModel: state.product,
                              userId: state.userId)),
                    ],
                  ),
                );
              }

              return SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.black),
          onPressed: () {
            context.push("/search");
          },
        ),
        IconButton(
          icon: Icon(Icons.home_outlined, color: Colors.black),
          onPressed: () {
            context.go("/home");
          },
        ),
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
          onPressed: () {
            context.push("/cart");
          },
        ),
      ],
    );
  }

  Widget _buildProductHeader(ProductModel product, String userId) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(product.productImageList),
          _buildProductInfo(product, userId),
          Container(height: 8.h, color: Colors.grey[200]),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return Stack(
      children: [
        //이미지
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.fill,
              );
            },
          ),
        ),
        Positioned(
          bottom: 16.h,
          right: 16.w, // 오른쪽 정렬로 변경
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Row의 크기를 내용물에 맞게 조절
              children: [
                Text(
                  '${_currentPage + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' / ${images.length}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(ProductModel product, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 브랜드 섹션
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    product.brandName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14.sp,
                        ),
                  ),
                  Icon(Icons.chevron_right, size: 18.sp),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context
                          .read<ProductDetailBloc>()
                          .add(TouchProductLikeEvent(product.productId));
                    },
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      child: Icon(
                        product.isFavorite(userId)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20.sp,
                        color: product.isFavorite(userId)
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      //공유 버튼
                      _shareProduct(context,product);
                    },
                      child: Image(
                        image: AssetImage('assets/image/kakaoshare.png'),  // 또는 NetworkImage
                        width: 20.sp,
                        height: 20.sp,
                      )
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                      onTap: () {
                        // 복사 버튼
                        _copyDeepLink(product.productId);
                      },
                      child: Icon(
                        Icons.copy,
                        size: 20.sp,
                      )
                  ),
                ],
              ),
            ],
          ),
        ),

        // 제품명 섹션
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            product.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16.sp,
                ),
          ),
        ),

        // 가격 섹션
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${formatPrice(product.price)}원',
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 14.sp,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${product.discountPercent}%',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    formatDiscountedPriceToString(
                        product.price, product.discountPercent.toDouble()),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '원',
                    style: TextStyle(
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 평점 섹션
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
          child: Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20.sp),
              Text(
                product.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                    ),
              ),
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                width: 1.w, // 세로선의 두께
                height: 12.sp, // 세로선의 높이
                color: AppsColor.darkGray, // 옅은 색
              ),
              SizedBox(width: 4.w),
              Text(
                '리뷰 ${product.reviewList.length}건',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15.sp,
                    ),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 1,
          color: AppsColor.lightGray,
        ),

        //배송정보 섹션
        Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "일반배송",
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              ),
              Text("2,500원 (20,000원 이상 무료배송 \n평균 3일 이내 도착",
                  style: TextStyle(fontSize: 13.sp)),
              Icon(Icons.chevron_right, size: 18.sp, color: Colors.grey),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.all(16.0.w),
          child: OutlinedButton(
            onPressed: () {
              context.push("/store_list", extra: product);
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '구매 가능 매장 찾기',
                  style: TextStyle(fontSize: 14.sp),
                ),
                Icon(Icons.chevron_right, size: 18.sp),
              ],
            ),
          ),
        ),

        SmallPromotionBanner(promotions: getOneBannerData()),
      ],
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      delegate: StickyTabBarDelegate(
        TabBar(
          onTap: (index) {
            if (index == 1) {
              context.read<ReviewBloc>().add(LoadReviewListEvent(widget.productId));
            }
          },
          tabs: [Tab(text: '상품설명'), Tab(text: '리뷰')],
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppsColor.pastelGreen,
          dividerColor: AppsColor.lightGray,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildTabBarView(ProductModel product, String userId) {
    return TabBarView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              ProductDescriptionTab(product: product),
              Container(height: 8.h, color: Colors.grey[200]),
              ExpansionTileWidget()
            ],
          ),
        ),
        BlocBuilder<ReviewBloc, ReviewState>(
          buildWhen: (previous, current) {
            // LoadedReviewState 상태일 때만 리빌드
            return current is LoadedReviewState;
          },
          builder: (context, state) {
            if(state is LoadedReviewState){
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReviewSummaryWidget(reviewList: state.reviewList, ratingAverage: state.reviewAverageRating, ratingPercentAge: state.reviewRatingPercentAge,),
                    Container(height: 8.h, color: Colors.grey[200]),
                    ReviewListWidget(reviewList: state.reviewList, userId: userId,),
                  ],
                ),
              );
            }
            return Text("review road error");
            },
        ),
      ],
    );
  }

  void showLikeAnimation(BuildContext context) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Icon(Icons.favorite, color: Colors.red, size: 84.sp),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry.remove();
    });
  }

  Future<void> _shareProduct(BuildContext context, ProductModel product) async {
    try {
      final dynamicLink = await DeepLinkService().createProductShareLink(productId: product.productId);

      print('Generated Dynamic Link: ${dynamicLink.toString()}');

      await _kakaoShareService.shareToKakao(
        title: product.name,
        description: "${product.discountPercent}% 할인중!\n${formatDiscountedPriceToString(product.price,product.discountPercent.toDouble())}원",
        link: dynamicLink,
        imageUrl: product.productImageList[0],
        productId: product.productId,
        buttonTitle: '상품 보러가기',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('공유하기에 실패했습니다.')),
      );
    }
  }

  Future<void> _copyDeepLink(String productId) async {
    final dynamicLink = await DeepLinkService().createProductShareLink(productId: productId);
    Clipboard.setData(ClipboardData(text: dynamicLink.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('제품 링크가 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
