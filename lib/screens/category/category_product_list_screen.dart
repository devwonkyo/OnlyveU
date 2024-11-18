import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/category/category_product_bloc.dart';
import 'package:onlyveyou/blocs/product/cart/product_cart_bloc.dart';
import 'package:onlyveyou/models/category_model.dart';
import 'package:onlyveyou/models/category_selection.dart';
import 'package:onlyveyou/screens/category/category_product_list_skeleton_screen.dart';
import 'package:onlyveyou/screens/category/widgets/filter_item.dart';
import 'package:onlyveyou/utils/dummy_data.dart';
import 'package:onlyveyou/utils/function_method.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/widgets/main_promotion_banner.dart';
import 'package:onlyveyou/widgets/product_widgets/vertical_product_card.dart';
import 'package:onlyveyou/widgets/small_promotion_banner.dart';

class CategoryProductListScreen extends StatefulWidget {
  final CategorySelection categorySelection;

  const CategoryProductListScreen({super.key, required this.categorySelection});

  @override
  _CategoryProductListScreenState createState() =>
      _CategoryProductListScreenState();
}

class _CategoryProductListScreenState extends State<CategoryProductListScreen> {
  late int _selectedFilterIndex;
  late List<Subcategory> _filterOptions;
  late final ScrollController _scrollController;
  bool isMainCategory = false;
  String? userId;
  //todo remove
  String? token;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedFilterIndex = getIndex()!;

    _initializeUserId();

    _filterOptions = [
      Subcategory(id: widget.categorySelection.category.id, name: "전체"),
      ...widget.categorySelection.category.subcategories
    ];
    //서브카테고리 없으면 메인카테고리
    if (widget.categorySelection.selectedSubcategoryId == null) {
      isMainCategory = true;
    }

    // BlocProvider를 통해 블록에 접근하여 초기 이벤트 발생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isMainCategory) {
        context.read<CategoryProductBloc>().add(GetProducts(
            filter: widget.categorySelection.category.id,
            isMainCategory: true));
      } else {
        context.read<CategoryProductBloc>().add(GetProducts(
            filter: widget.categorySelection.selectedSubcategoryId));
      }
      _scrollToSelectedIndex();
    });
  }

  Future<void> _initializeUserId() async {
    // 비동기 작업 수행
    String fetchedUserId = await OnlyYouSharedPreference().getCurrentUserId();
    //todo remove
    String fetchedUserToken = await OnlyYouSharedPreference().getToken();
    setState(() {
      userId = fetchedUserId; // 상태를 업데이트하여 UI 갱신
      token = fetchedUserToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.categorySelection.category.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black, size: 24.sp),
            onPressed: () {
              context.push('/search');
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined,
                color: Colors.black, size: 24.sp),
            onPressed: () {
              sendNotification(title: "알림",body: "테스트 푸시",pushToken: token ?? '');
            },
          ),
        ],
      ),
      body: BlocListener<ProductCartBloc, ProductCartState>(
        listener: (context, state) {
          if (state is AddCartError) {
            print(state.message);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${state.message}'),
              duration: Duration(seconds: 2), // 표시 지속 시간
            ));
          }
          if (state is AddCartSuccess) {
            print(state.message);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${state.message}'),
              duration: Duration(seconds: 2), // 표시 지속 시간
            ));
          }
        },
        child: BlocBuilder<CategoryProductBloc, CategoryProductState>(
          builder: (context, state) {
            return Column(
              children: [
                // 상단 필터 영역
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Row(
                    children: List.generate(
                      _filterOptions.length,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                          //대주제 선택
                          if (index == 0) {
                            context.read<CategoryProductBloc>().add(GetProducts(
                                filter: _filterOptions[index].id,
                                isMainCategory: true));
                            isMainCategory = true;
                          } else {
                            context.read<CategoryProductBloc>().add(
                                GetProducts(filter: _filterOptions[index].id));
                            isMainCategory = false;
                          }
                        },
                        child: FilterItem(
                          _filterOptions[index].name,
                          _selectedFilterIndex == index,
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(height: 1.h, color: Colors.grey[300]),
                // 서브 카테고리 및 정렬 옵션
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlocBuilder<CategoryProductBloc, CategoryProductState>(
                        builder: (context, state) {
                          return Text(
                            _filterOptions[_selectedFilterIndex].name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _showSortOptions(context);
                        },
                        icon: Icon(Icons.keyboard_arrow_down,
                            size: 20.sp, color: Colors.black87),
                        label: Text(
                          '인기순',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<CategoryProductBloc, CategoryProductState>(
                    builder: (context, state) {
                      if (state is CategoryProductLoading) {
                        return const CategoryProductListSkeletonScreen();
                      } else if (state is CategoryProductLoaded) {
                        final products = _selectedFilterIndex == 0
                            ? state.products
                            : state.products;
                        return CustomScrollView(
                          slivers: [
                            // 배너 영역
                            if (isMainCategory)
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    const MainPromotionBanner(),
                                    const SizedBox(height: 16),
                                    SmallPromotionBanner(
                                        promotions: getMultiBannerData()),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),

                            // 텍스트 영역
                            if (isMainCategory)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 12.h),
                                  child: Text(
                                    '${widget.categorySelection.category.name}에서 많이 본 상품이에요.',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            // 상품 그리드
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.5,
                                  crossAxisSpacing: 16.w,
                                  mainAxisSpacing: 24.h,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return VerticalProductCard(
                                        productModel: products[index],
                                        userId: userId ?? "",
                                        onTap: () => context.push(
                                            "/product-detail",
                                            extra: "1_4_1"));
                                            // extra: products[index].productId));
                                  },
                                  childCount: products.length,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Center(
                            child: Text('Error loading products'));
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  int? getIndex() {
    if (widget.categorySelection.selectedSubcategoryId == null) {
      return 0;
    } else {
      return int.tryParse(
          widget.categorySelection.selectedSubcategoryId!.split('_')[1]);
    }
  }

  void _scrollToSelectedIndex() {
    // 선택된 인덱스의 위치로 스크롤
    final selectedItemOffset = _selectedFilterIndex * 50.0; // 각 항목의 너비에 따라 조정
    _scrollController.animateTo(
      selectedItemOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('인기순'),
              onTap: () {
                // 인기순 정렬을 선택했을 때 동작
                Navigator.pop(context); // 바텀시트 닫기
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('최신순'),
              onTap: () {
                // 최신순 정렬을 선택했을 때 동작
                Navigator.pop(context); // 바텀시트 닫기
              },
            ),
            ListTile(
              leading: const Icon(Icons.price_change),
              title: const Text('가격순'),
              onTap: () {
                // 가격순 정렬을 선택했을 때 동작
                Navigator.pop(context); // 바텀시트 닫기
              },
            ),
          ],
        );
      },
    );
  }
}
