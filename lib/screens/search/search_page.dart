import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/repositories/product_repository.dart';
import 'package:onlyveyou/repositories/search_repositories/recent_search_repository/recent_search_repository_impl.dart';
import 'package:onlyveyou/repositories/search_repositories/suggestion_repository/suggestion_repository_impl.dart';
import 'package:onlyveyou/screens/search/search_home_screen/recent_search_view/bloc/recent_search_bloc.dart';
import 'package:onlyveyou/screens/search/search_result_screen/search_result_screen.dart';

import 'search_home_screen/search_home_screen.dart';
import 'search_result_screen/bloc/search_result_bloc.dart';
import 'search_suggestion_screen/bloc/search_suggestion_bloc.dart';
import 'search_suggestion_screen/search_suggestion_screen.dart';
import 'search_text_field/bloc/search_text_field_bloc.dart';
import 'search_text_field/search_text_field.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('==========$runtimeType==========');
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchTextFieldBloc>(
          create: (context) => SearchTextFieldBloc(),
        ),
        BlocProvider<RecentSearchBloc>(
          create: (context) => RecentSearchBloc(
            repository: RecentSearchRepositoryImpl(),
          ),
        ),
        BlocProvider(
          create: (context) => SearchSuggestionBloc(
            suggestionRepository: SuggestionRepositoryImpl(),
          ),
        ),
        BlocProvider(
          create: (context) => SearchResultBloc(
            productRepository: ProductRepository(),
          ),
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
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined,
                    color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
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
              BlocListener<SearchTextFieldBloc, SearchTextFieldState>(
                listener: (context, state) {
                  if (state is SearchTextFieldEmpty) {
                  } else if (state is SearchTextFieldTyping) {
                    context
                        .read<SearchSuggestionBloc>()
                        .add(FetchSearchSuggestions(state.text));
                  } else if (state is SearchTextFieldSubmitted) {
                    context
                        .read<SearchResultBloc>()
                        .add(FetchSearchResults(state.text));
                    context
                        .read<RecentSearchBloc>()
                        .add(AddSearchTerm(state.text));
                  }
                },
                child: BlocBuilder<SearchTextFieldBloc, SearchTextFieldState>(
                  builder: (context, state) {
                    if (state is SearchTextFieldEmpty) {
                      return const SearchHomeScreen();
                    } else if (state is SearchTextFieldTyping) {
                      return const SearchSuggestionScreen();
                    } else if (state is SearchTextFieldSubmitted) {
                      return const SearchResultScreen();
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
