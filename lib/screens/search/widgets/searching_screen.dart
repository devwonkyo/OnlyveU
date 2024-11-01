import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/search/filtered_tags/filtered_tags_cubit.dart';
import 'package:onlyveyou/blocs/search/tag_search/tag_search_cubit.dart';

class SearchingScreen extends StatelessWidget {
  const SearchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tags = context.watch<FilteredTagsCubit>().state.filteredTags;

    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: tags.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(tags[index].name),
          onTap: () {
            context.read<TagSearchCubit>().setSearchTerm(tags[index].name);
            FocusScope.of(context).unfocus();
          },
        );
      },
    );
  }
}
