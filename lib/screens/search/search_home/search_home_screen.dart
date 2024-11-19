import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/screens/search/search_home/recent_search/recent_search_view.dart';
import 'package:onlyveyou/screens/search/search_home/trend_search/trend_search_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../../blocs/search/search_text_field/search_text_field_bloc.dart';
import '../../../blocs/search/recent_search/recent_search_bloc.dart';
import '../../../blocs/search/trend_search/trend_search_bloc.dart';

class SearchHomeScreen extends StatelessWidget {
  const SearchHomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchTextFieldBloc, SearchTextFieldState>(
      listener: (context, state) {
        if (state is SearchTextFieldSubmitted) {
          context.read<RecentSearchBloc>().add(AddSearchTerm(state.text));
        }
      },
      child: Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              // 로컬 데이터
              BlocBuilder<RecentSearchBloc, RecentSearchState>(
                builder: (context, state) {
                  debugPrint(state.toString());
                  if (state is RecentSearchInitial) {
                    return const SizedBox();
                  } else if (state is RecentSearchLoading) {
                    return const RecentSkeleton();
                  } else if (state is RecentSearchLoaded) {
                    return SearchMainContainer(
                      title: '최근 검색어',
                      leading: GestureDetector(
                        onTap: () {
                          context
                              .read<RecentSearchBloc>()
                              .add(ClearAllSearchTerms());
                        },
                        child: Text(
                          '전체 삭제',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        height: 37.h,
                        child: RecentSearchView(
                          itemCount: state.recentSearches.length,
                          titleList: state.recentSearches,
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),

              // 서버 데이터
              BlocBuilder<TrendSearchBloc, TrendSearchState>(
                builder: (context, state) {
                  if (state is TrendSearchInitial) {
                    return const SizedBox();
                  } else if (state is TrendSearchLoading) {
                    return const Column(
                      children: [
                        RecentSkeleton(),
                        TrendSkeleton(),
                      ],
                    );
                  } else if (state is TrendSearchLoaded) {
                    return Column(
                      children: [
                        const RecommendSearchView(),
                        SearchMainContainer(
                          title: '인기 검색어',
                          leading: Text(
                            '${state.updateTime} 기준',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                          child: TreandSearchView(
                              trendSearches: state.trendSearches),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrendSkeleton extends StatelessWidget {
  const TrendSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 130.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: Row(
              children: [
                Container(
                  width: 90.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 100.w),
                Container(
                  width: 90.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: Row(
              children: [
                Container(
                  width: 130.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 60.w),
                Container(
                  width: 130.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentSkeleton extends StatelessWidget {
  const RecentSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 130.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: Row(
              children: [
                Container(
                  width: 80.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.r),
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  width: 80.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.r),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 35.h),
        ],
      ),
    );
  }
}

class RecommendSearchView extends StatelessWidget {
  const RecommendSearchView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SearchMainContainer(
      title: '추천 키워드',
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Wrap(
          spacing: 10.w,
          runSpacing: 7.h,
          children: [
            SizedBox(
              height: 37.h,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey[100],
                ),
                child: const Text('세미매트밀착쿠션'),
              ),
            ),
            SizedBox(
              height: 37.h,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey[100],
                ),
                child: const Text('콜라겐올인원'),
              ),
            ),
            SizedBox(
              height: 37.h,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey[100],
                ),
                child: const Text('히알루산올인원'),
              ),
            ),
            SizedBox(
              height: 37.h,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey[100],
                ),
                child: const Text('탱글젤리블리셔'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchMainContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? leading;
  const SearchMainContainer({
    super.key,
    required this.title,
    required this.child,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              if (leading != null) leading!,
            ],
          ),
        ),
        SizedBox(height: 15.h),
        child,
        SizedBox(height: 35.h),
      ],
    );
  }
}
