import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/models/search_models/suggestion_model.dart';
import 'package:onlyveyou/repositories/search_repositories/suggestion_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'search_event.dart';
part 'search_state.dart';

const _duration = Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SuggestionRepository suggestionRepository;

  SearchBloc({required this.suggestionRepository})
      : super(SearchInitialState()) {
    on<TextChangedEvent>(_onTextChangedEvent, transformer: debounce(_duration));
  }

  Future<void> _onTextChangedEvent(
    TextChangedEvent event,
    Emitter<SearchState> emit,
  ) async {
    final searchTerm = event.text;

    if (searchTerm.isEmpty) {
      return emit(SearchInitialState());
    }

    try {
      final suggestions = await suggestionRepository.search(searchTerm);
      emit(SearchSuggestionsState(suggestions));
    } catch (error) {
      emit(
        error is SearchErrorState
            ? SearchErrorState(error.message)
            : const SearchErrorState('something went wrong'),
      );
    }
  }
}
