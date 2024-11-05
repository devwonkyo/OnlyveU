import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/screens/search/search_text_field/bloc/search_text_field_bloc.dart';
import 'package:onlyveyou/screens/search/search_text_field/search_text_field.dart';
import 'package:onlyveyou/screens/search/search_home_view/search_home_view.dart';

import 'search_result_view/search_result_view.dart';
import 'search_suggestion_view/bloc/search_suggestion_bloc.dart';
import 'search_suggestion_view/search_suggestion_view.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('==========$runtimeType==========');
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchTextFieldBloc>(
          create: (context) => SearchTextFieldBloc(),
        ),
        BlocProvider(
          create: (context) => SearchSuggestionBloc(),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined,
                    color: Colors.black),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40.h), // 검색창의 높이 설정
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1.w),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: const SearchTextField(),
                ),
              ),
            ),
          ),
          body: BlocBuilder<SearchTextFieldBloc, SearchTextFieldState>(
            builder: (context, state) {
              return switch (state) {
                SearchTextFieldEmpty() => SearchHomeView(),
                SearchTextFieldTyping() => SearchSuggestionView(),
                SearchTextFieldSubmitted() => SearchResultView(),
                Object() => throw UnimplementedError(),
              };
            },
          ),
        ),
      ),
    );
  }
}
