import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchInitialScreen extends StatelessWidget {
  const SearchInitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchMainContainer(
              title: '최근 검색어',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      const RecentlySearchButton(name: '보습'),
                      SizedBox(width: 10.w),
                      const RecentlySearchButton(name: '스킨'),
                      SizedBox(width: 10.w),
                      const RecentlySearchButton(name: '아이라이너'),
                      SizedBox(width: 10.w),
                      const RecentlySearchButton(name: '선크림'),
                      SizedBox(width: 10.w),
                      const RecentlySearchButton(name: '쿠션'),
                    ],
                  ),
                ),
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
            SearchMainContainer(
              title: '급상승 검색어',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SizedBox(),
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

class RecentlySearchButton extends StatelessWidget {
  final String name;

  const RecentlySearchButton({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h)),
        child: Row(
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 15.sp),
            ),
            SizedBox(width: 5.w),
            Icon(
              Icons.close,
              size: 15.sp,
            ),
          ],
        ));
  }
}
