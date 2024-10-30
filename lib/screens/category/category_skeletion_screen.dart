import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CategorySkeletonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 왼쪽 메인 카테고리 스켈레톤
          Container(
            width: 100.w,
            color: Colors.grey[50],
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 15, // 예시 아이템 수
              itemBuilder: (context, index) {
                return SkeletonItem(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 15.h,
                      horizontal: 12.w,
                    ),
                    height: 15.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                );
              },
            ),
          ),

          // 오른쪽 서브카테고리 스켈레톤
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                // 첫 번째 섹션 헤더 스켈레톤
                _buildSectionHeaderSkeleton(),
                SizedBox(height: 10.h),

                // 첫 번째 섹션 아이템들
                _buildSectionItemsSkeleton(),
                SizedBox(height: 20.h),

                // 두 번째 섹션 헤더 스켈레톤
                _buildSectionHeaderSkeleton(),
                SizedBox(height: 10.h),

                // 두 번째 섹션 아이템들
                _buildSectionItemsSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderSkeleton() {
    return Row(
      children: [
        SkeletonItem(
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: SkeletonItem(
            child: Container(
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildSectionItemsSkeleton() {
    return Column(
      children: List.generate(
        5,
            (index) => Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: SkeletonItem(
            child: Container(
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SkeletonItem extends StatelessWidget {
  final Widget child;

  const SkeletonItem({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}