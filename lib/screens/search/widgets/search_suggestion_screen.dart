import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/search/search/search_bloc.dart';
import '../../../models/search_models/search_models.dart';

class SearchSuggestionScreen extends StatelessWidget {
  const SearchSuggestionScreen({
    Key? key,
    required this.suggestions,
    required this.controller,
  }) : super(key: key);

  final List<SuggestionModel> suggestions;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].term),
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.text = suggestions[index].term;
            context
                .read<SearchBloc>()
                .add(ShowResultEvent(text: suggestions[index].term));
          },
        );
      },
    );
  }
}
