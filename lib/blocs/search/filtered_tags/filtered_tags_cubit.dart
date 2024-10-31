import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/tag_model.dart';

part 'filtered_tags_state.dart';

class FilteredTagsCubit extends Cubit<FilteredTagsState> {
  final List<Tag> initialTags;

  FilteredTagsCubit({
    required this.initialTags,
  }) : super(FilteredTagsState(filteredTags: initialTags));

  void setFilteredTodos(String searchTerm) {
    List<Tag> filteredTags = initialTags;

    if (searchTerm.isNotEmpty) {
      filteredTags = filteredTags
          .where(
            (todo) => todo.name.toLowerCase().contains(searchTerm),
          )
          .toList();
    }

    emit(state.copyWith(filteredTags: filteredTags));
  }
}
