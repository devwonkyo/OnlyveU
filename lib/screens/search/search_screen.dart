import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/search/search_navigation/search_navigation_bloc.dart';
import 'package:onlyveyou/blocs/search/tag_search/tag_search_cubit.dart';
import 'package:onlyveyou/screens/search/widgets/search_complete_screen.dart';
import 'package:onlyveyou/screens/search/widgets/searching_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widgets/search_initial_screen.dart';
import 'widgets/search_text_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    _messageController.text = context.watch<TagSearchCubit>().state.searchTerm;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.shopping_bag_outlined, color: Colors.black),
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
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: SearchTextField(
                  controller: _messageController,
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ),
        ),
        body:
            // BlocBuilder<SearchNavigationBloc, SearchNavigationState>(
            //   builder: (context, state) {
            //     switch (state.) {
            //       case SearchNavigationSelected(selectedSearchStatus: SearchStatus.initial):
            //         return Center(child: CircularProgressIndicator());
            //       case GetTopicLoaded:
            //         return YourWidget();
            //       case GetTopicError:
            //         return ErrorWidget();
            //       default:
            //         return Container();
            //     }
            //   },
            // )
            // context.watch<TagSearchCubit>().state.searchTerm.isEmpty
            //     ? const SearchInitialScreen()
            //     : const SearchingScreen(),
            SearchCompleteScreen(),
      ),
    );
  }
}
