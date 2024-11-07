import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../search_home_screen/search_home_screen.dart';
import '../search_text_field/bloc/search_text_field_bloc.dart';
import 'bloc/search_suggestion_bloc.dart';

class SearchSuggestionScreen extends StatelessWidget {
  const SearchSuggestionScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchSuggestionBloc, SearchSuggestionState>(
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
    );
  }
}
