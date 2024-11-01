import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/core/router.dart';
import 'package:onlyveyou/cubit/category/category_cubit.dart';
import 'package:onlyveyou/models/category_selection.dart';
import 'package:onlyveyou/screens/category/category_skeletion_screen.dart';
import 'package:onlyveyou/screens/category/widgets/main_category_item.dart';
import 'package:onlyveyou/screens/category/widgets/sub_category_header.dart';
import 'package:onlyveyou/screens/category/widgets/sub_category_item.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';

class CategoryScreen extends StatefulWidget {
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController _rightScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // 스크롤 리스너 추가
    _rightScrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(mainColor: AppsColor.pastelGreen),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return CategorySkeletonScreen();
          }

          if (state is CategoryLoaded) {
            print('reload');
            return Row(
              children: [
                //필요하면 카테고리 추가

                // 왼쪽 메인 카테고리 리스트
                Container(
                  width: 100.w,
                  color: Colors.grey[50],
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      final isSelected =
                          context.read<CategoryCubit>().selectedIndex == index;

                      return MainCategoryItem(
                        category: category,
                        isSelected: isSelected,
                        onTap: () {
                          context.read<CategoryCubit>().selectCategory(index);
                          _scrollToCategory(index);  // 여기서 스크롤 호출
                          print(index);
                        },
                      );
                    },
                  ),
                ),

                // 오른쪽 서브카테고리 리스트
                Expanded(
                  child:ListView.builder(
                    controller: _rightScrollController,  // 컨트롤러 연결
                    itemCount: state.categories.length,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // 클릭 시 실행할 코드
                              print("카테고리 헤더 클릭 : ${category.name}");
                              final categorySelection = CategorySelection(category: category);
                              context.push("/categroy/productlist",extra: categorySelection);
                            },
                            child: // 카테고리 헤더
                            SubCategoryHeader(
                              icon : category.icon ?? "",  // 아이콘은 적절히 변경
                              title: category.name,
                              hasArrow: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 서브카테고리 목록
                          ...category.subcategories.map((subcategory) =>
                              GestureDetector(
                                onTap: () {
                                  // 클릭 시 실행할 코드
                                  print('click ${subcategory.name}');
                                  final categorySelection = CategorySelection(category: category, selectedSubcategoryId: subcategory.id);
                                  context.push("/categroy/productlist",extra: categorySelection);
                                },
                                child: SubCategoryItem(title: subcategory.name),
                              )
                          ).toList(),
                          // 구분선
                          const Divider(
                            color: AppsColor.lightGray,
                            thickness: 1.0,
                            height: 10,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _scrollToTop, // 버튼 클릭 시 맨 위로 스크롤
        backgroundColor: Colors.white, // 버튼 배경색
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // 모서리 반지름
          side: const BorderSide(
            color: AppsColor.lightGray, // 테두리 색상
            width: 1.0, // 테두리 두께
          ),
        ),
        elevation: 0,
        child: const Icon(
          Icons.arrow_upward_outlined,
          color: AppsColor.darkGray, // 아이콘 색상
        ),
      ),// 위로 이동 아이콘
    );
  }

  // 스크롤 위치에 따른 카테고리 선택
  void _onScroll() {
    if (!mounted) return;

    final state = context.read<CategoryCubit>().state;
    if (state is! CategoryLoaded) return;

    double scrollOffset = _rightScrollController.offset;
    double totalHeight = 0;
    int currentIndex = 0;

    for (int i = 0; i < state.categories.length; i++) {
      // SubCategoryHeader 정확한 높이 계산
      double headerHeight = 32.h + // vertical padding (16.h * 2)
          max(36.r, // 아이콘 컨테이너 (20.sp + 16.r for padding)
              15.sp); // 텍스트 높이

      // SubCategoryItem 정확한 높이 계산
      double itemHeight = 24.h + // vertical padding (12.h * 2)
          14.sp; // 텍스트 높이

      // 현재 카테고리의 전체 높이 계산
      double categoryHeight = headerHeight + // 헤더
          (state.categories[i].subcategories.length * itemHeight) + // 아이템들
          8.h + // SizedBox
          1.h; // Divider (실제 높이)

      if (scrollOffset >= totalHeight && scrollOffset < (totalHeight + categoryHeight)) {
        currentIndex = i;
        break;
      }

      totalHeight += categoryHeight;
    }

    if (context.read<CategoryCubit>().selectedIndex != currentIndex) {
      context.read<CategoryCubit>().selectCategory(currentIndex);
    }
  }

// 카테고리 클릭 시 스크롤 처리도 동일하게 수정
  void _scrollToCategory(int index) {
    final state = context.read<CategoryCubit>().state as CategoryLoaded;
    double totalHeight = 0;

    for (int i = 0; i < index; i++) {
      // SubCategoryHeader 정확한 높이 계산
      double headerHeight = 32.h + // vertical padding (16.h * 2)
          max(36.r, // 아이콘 컨테이너 (20.sp + 16.r for padding)
              15.sp); // 텍스트 높이

      // SubCategoryItem 정확한 높이 계산
      double itemHeight = 24.h + // vertical padding (12.h * 2)
          14.sp; // 텍스트 높이

      totalHeight += headerHeight + // 헤더
          (state.categories[i].subcategories.length * itemHeight) + // 아이템들
          8.h + // SizedBox
          1.h; // Divider (실제 높이)
    }

    // 스크롤 위치에 패딩 고려
    final padding = 16.w; // ListView의 수평 패딩 값

    _rightScrollController.animateTo(
      totalHeight,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _rightScrollController.removeListener(_onScroll);
    _rightScrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    // 스크롤을 맨 위로 이동
    _rightScrollController.animateTo(
      0, // 맨 위로 이동
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}