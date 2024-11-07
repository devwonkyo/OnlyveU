import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/screens/search/search_home_screen/recent_search_view/recent_search_view.dart';

import '../../../repositories/search_repositories/recent_search_repository/recent_search_repository_impl.dart';
import 'recent_search_view/bloc/recent_search_bloc.dart';

class SearchHomeScreen extends StatelessWidget {
  const SearchHomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecentSearchBloc>(
          create: (context) => RecentSearchBloc(
            repository: RecentSearchRepositoryImpl(),
          ),
        ),
      ],
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 로컬 데이터
              SearchMainContainer(
                title: '최근 검색어',
                child: SizedBox(
                  height: 40.h,
                  child: const RecentSearchView(),
                ),
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
                      FilledButton(
                          onPressed: () {}, child: const Text('콜라겐올인원')),
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
              const SearchMainContainer(
                title: '급상승 검색어',
                child: SizedBox(),
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
