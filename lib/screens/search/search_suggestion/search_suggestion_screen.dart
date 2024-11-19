import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/search/recent_search/recent_search_bloc.dart';
import '../search_home/search_home_screen.dart';
import '../../../blocs/search/search_text_field/search_text_field_bloc.dart';
import '../../../blocs/search/search_suggestion/search_suggestion_bloc.dart';

class SearchSuggestionScreen extends StatelessWidget {
  const SearchSuggestionScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchTextFieldBloc, SearchTextFieldState>(
      listener: (context, state) {
        if (state is SearchTextFieldSubmitted) {
          context.read<RecentSearchBloc>().add(AddSearchTerm(state.text));
        }
      },
      child: BlocBuilder<SearchSuggestionBloc, SearchSuggestionState>(
        builder: (context, state) {
          if (state is SearchSuggestionInitial) {
            return const SearchHomeScreen();
          } else if (state is SearchSuggestionLoading) {
            return const SizedBox();
          } else if (state is SearchSuggestionLoaded) {
            return ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: state.suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(state.suggestions[index].term),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    context
                        .read<SearchTextFieldBloc>()
                        .add(TextSubmitted(state.suggestions[index].term));
                    context.read<SearchSuggestionBloc>().add(
                        IncrementPopularity(state.suggestions[index].term,
                            state.suggestions[index].popularity));
                  },
                );
              },
            );
          } else if (state is SearchSuggestionError) {
            return const Center(child: Text('error'));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
