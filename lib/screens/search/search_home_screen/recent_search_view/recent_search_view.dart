import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:onlyveyou/screens/search/search_text_field/bloc/search_text_field_bloc.dart';

import 'bloc/recent_search_bloc.dart';

class RecentSearchView extends StatelessWidget {
  const RecentSearchView({
    super.key,
    required this.itemCount,
    required this.titleList,
  });
  final int itemCount;
  final List<String> titleList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: RecentlySearchButton(
            title: titleList[index],
          ),
        );
      },
    );
  }
}

class RecentlySearchButton extends StatelessWidget {
  final String title;

  const RecentlySearchButton({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          context.read<SearchTextFieldBloc>().add(TextSubmitted(title));
        },
        style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h)),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 15.sp),
            ),
            SizedBox(width: 5.w),
            GestureDetector(
              onTap: () {
                context.read<RecentSearchBloc>().add(RemoveSearchTerm(title));
                context.read<RecentSearchBloc>().add(LoadRecentSearches());
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
