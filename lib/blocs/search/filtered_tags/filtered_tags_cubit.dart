import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/tag_model.dart';

import '../tag_search/tag_search_cubit.dart';

part 'filtered_tags_state.dart';

class FilteredTagsCubit extends Cubit<FilteredTagsState> {
  late StreamSubscription tagSearchSubscription;

  final List<Tag> initialTags;

  final TagSearchCubit tagSearchCubit;
  FilteredTagsCubit({
    required this.initialTags,
    required this.tagSearchCubit,
  }) : super(FilteredTagsState(filteredTags: initialTags)) {
    tagSearchSubscription = tagSearchCubit.stream.listen((event) {
      setFilteredTodos();
    });
  }

  void setFilteredTodos() {
    List<Tag> filteredTags = initialTags;

    if (tagSearchCubit.state.searchTerm.isNotEmpty) {
      filteredTags = filteredTags
          .where(
            (todo) => todo.name
                .toLowerCase()
                .contains(tagSearchCubit.state.searchTerm),
          )
          .toList();
    }

    emit(state.copyWith(filteredTags: filteredTags));
  }

  @override
  Future<void> close() {
    tagSearchSubscription.cancel();
    return super.close();
  }
}
