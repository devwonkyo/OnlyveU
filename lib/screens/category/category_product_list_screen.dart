import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/category/category_bloc.dart';
import 'package:onlyveyou/screens/category/widgets/filter_item.dart';
import 'package:onlyveyou/screens/category/widgets/product_item.dart';

class CategoryProductListScreen extends StatefulWidget {
  const CategoryProductListScreen({super.key});

  @override
  _CategoryProductListScreenState createState() => _CategoryProductListScreenState();
}

class _CategoryProductListScreenState extends State<CategoryProductListScreen> {
  late final CategoryBloc _categoryBloc;
  int _selectedFilterIndex = 0;
  List<String> _filterOptions = ['전체', '시트팩', '패드', '페이셜팩', '코팩', '패치'];

  @override
  void initState() {
    super.initState();
    _categoryBloc = CategoryBloc()..add(GetProducts());
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
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '마스크팩',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black, size: 24.sp),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocProvider(
        create: (_) => _categoryBloc,
        child: Column(
          children: [
            // 상단 필터 영역
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _filterOptions.length,
                      (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                      _categoryBloc.add(GetProducts(filter: _filterOptions[index]));
                    },
                    child: FilterItem(
                      _filterOptions[index],
                      _selectedFilterIndex == index,
                    ),
                  ),
                ),
              ),
            ),
            Divider(height: 1.h, color: Colors.grey[300]),

            // 서브 카테고리 및 정렬 옵션
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      return Text(
                        _filterOptions[_selectedFilterIndex],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      Text(
                        '인기순',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, size: 20.sp),
                    ],
                  ),
                ],
              ),
            ),

            // 제품 그리드 리스트
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CategoryLoaded) {
                    final products = _selectedFilterIndex == 0
                        ? state.products
                        : state.products;
                    return GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 24.h,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductItem();
                      },
                    );
                  } else {
                    return const Center(child: Text('Error loading products'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryBloc.close();
    super.dispose();
  }
}