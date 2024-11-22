import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/repositories/product_repository.dart';
import 'package:onlyveyou/repositories/search_repositories/recent_search_repository/recent_search_repository_impl.dart';
import 'package:onlyveyou/repositories/search_repositories/suggestion_repository/suggestion_repository_impl.dart';
import 'package:onlyveyou/blocs/search/recent_search/recent_search_bloc.dart';
import 'package:onlyveyou/screens/search/search_result/search_result_screen.dart';

import 'search_home/search_home_screen.dart';
import '../../blocs/search/trend_search/trend_search_bloc.dart';
import '../../blocs/search/search_result/search_result_bloc.dart';
import '../../blocs/search/search_suggestion/search_suggestion_bloc.dart';
import 'search_suggestion/search_suggestion_screen.dart';
import '../../blocs/search/search_textfield/search_textfield_bloc.dart';
import 'search_textfield/search_textfield.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('==========$runtimeType==========');
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
        BlocProvider<TrendSearchBloc>(
          create: (context) => TrendSearchBloc(
            repository: SuggestionRepositoryImpl(),
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
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              _buildTextField(),
              _buildScreen(),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildScreen() {
    return Expanded(
      child: BlocListener<SearchTextFieldBloc, SearchTextFieldState>(
        listener: (context, state) {
          if (state is SearchTextFieldTyping) {
            context
                .read<SearchSuggestionBloc>()
                .add(FetchSearchSuggestions(state.text));
          } else if (state is SearchTextFieldSubmitted) {
            context
                .read<SearchResultBloc>()
                .add(FetchSearchResults(state.text));
          }
        },
        child: BlocBuilder<SearchTextFieldBloc, SearchTextFieldState>(
          builder: (context, state) {
            debugPrint(state.toString());
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
    );
  }

  Container _buildTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1.w),
        ),
      ),
      child: const SearchTextField(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 50.h,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
          onPressed: () {
            context.push('/cart');
          },
        ),
      ],
    );
  }
}
