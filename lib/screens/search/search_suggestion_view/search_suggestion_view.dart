import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../search_text_field/bloc/search_text_field_bloc.dart';
import 'bloc/search_suggestion_bloc.dart';

class SearchSuggestionView extends StatelessWidget {
  const SearchSuggestionView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchTextFieldBloc, SearchTextFieldState>(
      builder: (context, textFieldState) {
        String texts = '';
        if (textFieldState is SearchTextFieldTyping) {
          texts = textFieldState.text;
          context
              .read<SearchSuggestionBloc>()
              .add(FetchSearchSuggestions(texts));
        }
        print('내가 쓸거: ${texts}');
        return BlocBuilder<SearchSuggestionBloc, SearchSuggestionState>(
          builder: (context, state) {
            if (state is SearchSuggestionInitial) {
              return Center(
                  child: Text("Enter a search term to see suggestions"));
            } else if (state is SearchSuggestionLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is SearchSuggestionLoaded) {
              return Center(child: Text('$texts'));
              // ListView.builder(
              //   primary: false,
              //   shrinkWrap: true,
              //   itemCount: state.suggestions.length,
              //   itemBuilder: (context, index) {
              //     return ListTile(
              //       title: Text(state.suggestions[index]),
              //       onTap: () {},
              //     );
              //   },
              // );
            } else if (state is SearchSuggestionError) {
              return Center(child: Text(state.message));
            } else {
              return Center(child: Text("Unknown state"));
            }
          },
        );
      },
    );

    // ListView.builder(
    //   primary: false,
    //   shrinkWrap: true,
    //   itemCount: suggestions.length,
    //   itemBuilder: (context, index) {
    //     return ListTile(
    //       title: Text(suggestions[index].term),
    //       onTap: () {
    //         FocusScope.of(context).unfocus();
    //         controller.text = suggestions[index].term;
    //         context
    //             .read<SearchBloc>()
    //             .add(ShowResultEvent(text: suggestions[index].term));
    //         _searchService.saveRecentSearch(suggestions[index].term);
    //       },
    //     );
    //   },
    // );
  }
}
