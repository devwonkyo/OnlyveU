import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/screens/search/widgets/search_result_screen.dart';
import 'package:onlyveyou/screens/search/widgets/search_suggestion_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../blocs/search/search/search_bloc.dart';
import 'widgets/search_initial_screen.dart';
import 'widgets/search_service.dart';
import 'widgets/search_text_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SearchService _searchService = SearchService();

  void _sendMessage() {
    FocusScope.of(context).unfocus();
    context
        .read<SearchBloc>()
        .add(ShowResultEvent(text: _messageController.text));
    _searchService.saveRecentSearch(_messageController.text);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        // 나중에 리팩토링
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (_messageController.text.isEmpty) {
              state = SearchInitialState();
            }
            return switch (state) {
              SearchInitialState() =>
                SearchInitialScreen(controller: _messageController),
              SearchSuggestionState() => SearchSuggestionScreen(
                  suggestions: state.suggestions,
                  controller: _messageController,
                ),
              SearchResultState() => SearchResultScreen(results: state.results),
              SearchErrorState() => Text(state.message),
              SearchLoadingState() =>
                const Center(child: CircularProgressIndicator()),
            };
          },
        ),
      ),
    );
  }
}
