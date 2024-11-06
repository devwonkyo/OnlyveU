import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/product/productdetail_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/screens/Product/widgets/expandable_bottom_sheet.dart';
import 'package:onlyveyou/utils/format_price.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController();
    _scrollController.addListener(_scrollListener);
    context.read<ProductDetailBloc>().add(
          LoadProductDetail(widget.productId),
        );
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
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 앱바
              _buildAppBar(),
              // 상품 정보
              SliverToBoxAdapter(
                child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
                  builder: (context, state) {
                    if (state is ProductDetailLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ProductDetailError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ProductDetailLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(state.product),
                          _buildProductInfo(state.product),
                          _buildImageSection(state.product),
                          _buildImageSection(state.product),
                          _buildImageSection(state.product),
                          const SizedBox(height: 100), // 하단 버튼 공간
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          // 하단 고정 버튼
          BlocConsumer<ProductDetailBloc, ProductDetailState>(
            listener: (context, state) {

            },
            builder: (context, state) {
              if (state is ProductDetailLoaded) {
                return ExpandableBottomSheet(productModel: state.product);
              }else{
                return const SizedBox.shrink();
              }
              },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      scrolledUnderElevation: 0,
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        iconSize: 24.sp,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
          iconSize: 24.sp,
        ),
        IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () {},
          iconSize: 24.sp,
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {},
          iconSize: 24.sp,
        ),
      ],
    );
  }

  Widget _buildImageSection(ProductModel product) {
    return Stack(
      children: [
        //이미지
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            controller: _pageController,
            itemCount: product.productImageList.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                product.productImageList[index],
                fit: BoxFit.cover,
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
                  ' / ${product.productImageList.length}',
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

  Widget _buildProductInfo(ProductModel product) {
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
                      // 버튼이 눌렸을 때의 동작
                    },
                    child: Icon(
                      Icons.favorite_border,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      // 버튼이 눌렸을 때의 동작
                    },
                    child: Icon(
                      Icons.share,
                      size: 20.sp,
                    ),
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
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // 원하는 radius 값
                  ),
                ),
                child: Text(
                  '장바구니',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
                  ) // 원하는 radius 값
                ),
                child: Text(
                  '바로구매',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
