import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../search_home/recent_search/bloc/recent_search_bloc.dart';
import '../search_home/recent_search/recent_search_view.dart';
import '../search_text_field/bloc/search_text_field_bloc.dart';
import '../../../utils/search/suggestion/suggestion_button.dart';

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
                    child: SizedBox(
                      height: 40.h,
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
            SizedBox(height: 20.h),
            SearchMainContainer(
              title: '추천 키워드',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Wrap(
                  spacing: 10.w,
                  children: [
                    FilledButton(
                        onPressed: () {}, child: const Text('세미매트밀착쿠션')),
                    FilledButton(onPressed: () {}, child: const Text('콜라겐올인원')),
                    FilledButton(
                        onPressed: () {}, child: const Text('히알루산올인원')),
                    FilledButton(
                        onPressed: () {}, child: const Text('탱글젤리블리셔')),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // 서버 데이터
            SearchMainContainer(
              title: '급상승 검색어',
              child:
                  // const SizedBox(),
                  Column(
                children: [
                  BrandSuggestionUpdateButton(),
                  CategorySuggestionUpdateButton(),
                ],
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
  const SearchMainContainer({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 20.w),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        child,
      ],
    );
  }
}
