import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/search/search_suggestion/search_suggestion_bloc.dart';

import '../../../../models/search_models/search_models.dart';
import '../../../../blocs/search/search_textfield/search_textfield_bloc.dart';

class TreandSearchView extends StatelessWidget {
  const TreandSearchView({
    super.key,
    required this.trendSearches,
  });

  final List<SuggestionModel> trendSearches;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: SizedBox(
        height: 170.h,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10.h,
          runSpacing: 30.w,
          direction: Axis.vertical,
          children: List.generate(
            10,
            (index) {
              final trendSearch = trendSearches[index];
              return InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  context
                      .read<SearchTextFieldBloc>()
                      .add(TextSubmitted(trendSearch.term));
                  context.read<SearchSuggestionBloc>().add(IncrementPopularity(
                      trendSearch.term, trendSearch.popularity));
                },
                child: SizedBox(
                  width: 150.w,
                  child: Row(
                    children: [
                      // 순위
                      SizedBox(
                        width: 30.w,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // 검색어
                      Expanded(
                        child: Text(
                          trendSearch.term,
                          style: TextStyle(
                            fontSize: 13.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
