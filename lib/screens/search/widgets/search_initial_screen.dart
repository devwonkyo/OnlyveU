import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../blocs/search/search/search_bloc.dart';
import 'search_service.dart';

class SearchInitialScreen extends StatefulWidget {
  SearchInitialScreen({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;
  List<String> recentSearches = [];

  @override
  State<SearchInitialScreen> createState() => _SearchInitialScreenState();
}

class _SearchInitialScreenState extends State<SearchInitialScreen> {
  final SearchService _searchService = SearchService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadRecentSearches());
  }

  Future<void> _loadRecentSearches() async {
    final recentSearches = await _searchService.loadRecentSearches();
    setState(() {
      widget.recentSearches = recentSearches;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build!!!!: ${widget.recentSearches}');
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchMainContainer(
              title: '최근 검색어',
              child: SizedBox(
                height: 40.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.recentSearches.length,
                  itemBuilder: (context, index) {
                    final sortedRecentSearches =
                        List<String>.from(widget.recentSearches.reversed);
                    return Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: RecentlySearchButton(
                        name: sortedRecentSearches[index],
                        controller: widget.controller,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SearchMainContainer(
              title: '추천 키워드',
              child: Wrap(
                spacing: 10.w,
                children: [
                  FilledButton(onPressed: () {}, child: const Text('세미매트밀착쿠션')),
                  FilledButton(onPressed: () {}, child: const Text('콜라겐올인원')),
                  FilledButton(onPressed: () {}, child: const Text('히알루산올인원')),
                  FilledButton(onPressed: () {}, child: const Text('탱글젤리블리셔')),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SearchMainContainer(
              title: '급상승 검색어',
              child: SizedBox(),
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: child,
        ),
      ],
    );
  }
}

class RecentlySearchButton extends StatelessWidget {
  final String name;
  final TextEditingController controller;
  final SearchService _searchService = SearchService();

  RecentlySearchButton({
    super.key,
    required this.name,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          controller.text = name;
          context.read<SearchBloc>().add(ShowResultEvent(text: name));
          _searchService.saveRecentSearch(controller.text);
        },
        style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h)),
        child: Row(
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 15.sp),
            ),
            SizedBox(width: 5.w),
            GestureDetector(
              onTap: () {
                _searchService.removeRecentSearch(name);
              },
              child: Icon(
                Icons.close,
                size: 15.sp,
              ),
            ),
          ],
        ));
  }
}
