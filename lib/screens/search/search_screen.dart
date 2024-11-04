import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/search/search/search_bloc.dart';
import 'package:onlyveyou/screens/search/search_text_field/bloc/search_text_field_bloc.dart';
import 'package:onlyveyou/screens/search/search_text_field/search_text_field.dart';
import 'package:onlyveyou/screens/search/search_view/bloc/search_view_bloc.dart';
import 'package:onlyveyou/screens/search/widgets/search_initial_screen.dart';
import 'package:onlyveyou/screens/search/widgets/search_service.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchTextFieldBloc>(
          create: (context) => SearchTextFieldBloc(),
        ),
        BlocProvider<SearchViewBloc>(
          create: (context) => SearchViewBloc(),
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
                  child: SearchTextField(
                      // controller: _messageController,
                      // onSubmitted: _sendMessage,
                      ),
                ),
              ),
            ),
          ),
          // 나중에 리팩토링
          body: BlocBuilder<SearchViewBloc, SearchViewState>(
            builder: (context, state) {
              return switch (state) {
                Home() => SearchInitialScreen(controller: _messageController),
                Suggestion() =>
                  // SearchSuggestionScreen(
                  //     suggestions: state.suggestions,
                  //     controller: _messageController,
                  //   ),
                  const Center(child: CircularProgressIndicator()),
                Result() =>
                  // SearchResultScreen(results: state.results),
                  const Center(child: CircularProgressIndicator()),
                Loading() => const Center(child: CircularProgressIndicator()),
                Object() => throw UnimplementedError(),
              };
            },
          ),
        ),
      ),
    );
  }
}
