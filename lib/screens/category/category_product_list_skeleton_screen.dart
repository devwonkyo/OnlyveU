import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CategoryProductListSkeletonScreen extends StatelessWidget {
  const CategoryProductListSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상품 그리드 스켈레톤
        Expanded(
          child: _buildProductGrid(),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 40.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Container(
              width: 60.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortingOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 80.w,
              height: 20.h,
              color: Colors.white,
            ),
            Container(
              width: 60.w,
              height: 20.h,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 24.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildProductCard(),
    );
  }

  Widget _buildProductCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지 영역
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 8.h),
            // 상품 정보 영역
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상품명
                  Container(
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    height: 16.h,
                    width: 150.w,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  // 할인율 & 가격
                  Row(
                    children: [
                      Container(
                        width: 45.w,
                        height: 16.h,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 80.w,
                        height: 16.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // 평점
                  Row(
                    children: [
                      Container(
                        width: 20.w,
                        height: 16.h,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Container(
                        width: 30.w,
                        height: 16.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}