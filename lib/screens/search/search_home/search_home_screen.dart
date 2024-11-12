import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/screens/search/search_home/recent_search/recent_search_view.dart';
import 'package:onlyveyou/screens/search/search_home/trend_search/trend_search_view.dart';

import '../search_text_field/bloc/search_text_field_bloc.dart';
import 'recent_search/bloc/recent_search_bloc.dart';
// import '../../../utils/search/suggestion/suggestion_button.dart';

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
                  print(state);
                  if (state is RecentSearchInitial) {
                    return const SizedBox();
                  } else if (state is RecentSearchLoading) {
                    return const Center(child: Text('나중에 로딩화면 구현하기'));
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
              SearchMainContainer(
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
              ),
              // 서버 데이터
              SearchMainContainer(
                title: '급상승 검색어',
                leading: Text(
                  '22:40 기준',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                child: const TreandSearchView(),
                // Column(
                // children: [
                //   BrandSuggestionUpdateButton(),
                //   CategorySuggestionUpdateButton(),
                // ],
                // ),
              ),
            ],
          ),
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
