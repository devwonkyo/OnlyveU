import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../models/search_models/search_models.dart';
import '../../../../repositories/search_repositories/suggestion_repository/suggestion_repository.dart';

part 'search_suggestion_event.dart';
part 'search_suggestion_state.dart';

class SearchSuggestionBloc
    extends Bloc<SearchSuggestionEvent, SearchSuggestionState> {
  final SuggestionRepository suggestionRepository;
  SearchSuggestionBloc({required this.suggestionRepository})
      : super(SearchSuggestionInitial()) {
    on<FetchSearchSuggestions>(_onFetchSearchSuggestions);
  }

  Future<void> _onFetchSearchSuggestions(
    FetchSearchSuggestions event,
    Emitter<SearchSuggestionState> emit,
  ) async {
    emit(SearchSuggestionLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final suggestions = await suggestionRepository.search(event.query);
      emit(SearchSuggestionLoaded(suggestions));
    } catch (e) {
      emit(const SearchSuggestionError('Failed to fetch suggestions'));
    }
  }
}
