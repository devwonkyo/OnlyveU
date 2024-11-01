import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'tag_search_state.dart';

class TagSearchCubit extends Cubit<TagSearchState> {
  TagSearchCubit() : super(TagSearchState.initial());

  void setSearchTerm(String newSearchTerm) {
    emit(state.copyWith(searchTerm: newSearchTerm));
  }
}
