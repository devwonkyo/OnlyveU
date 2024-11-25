import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:onlyveyou/blocs/search/search_textfield/search_textfield_bloc.dart';

import '../../../../blocs/search/recent_search/recent_search_bloc.dart';

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
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 13.sp),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () {
                context.read<RecentSearchBloc>().add(RemoveSearchTerm(title));
              },
              child: Icon(
                Icons.close,
                size: 15.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ));
  }
}
