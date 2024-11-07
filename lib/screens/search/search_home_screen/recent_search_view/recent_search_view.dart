import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/screens/search/search_text_field/bloc/search_text_field_bloc.dart';

import 'bloc/recent_search_bloc.dart';

class RecentSearchView extends StatelessWidget {
  const RecentSearchView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentSearchBloc, RecentSearchState>(
      builder: (context, state) {
        print(state);
        if (state is RecentSearchInitial) {
          return const SizedBox();
        } else if (state is RecentSearchLoading) {
          return const Center(child: Text('나중에 로딩화면 구현하기'));
        } else if (state is RecentSearchLoaded) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            scrollDirection: Axis.horizontal,
            itemCount: state.recentSearches.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: RecentlySearchButton(
                  title: state.recentSearches[index],
                ),
              );
            },
          );
        } else {
          return const SizedBox();
        }
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
