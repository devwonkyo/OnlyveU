import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/models/search_models/suggestion_model.dart';
import 'package:onlyveyou/repositories/product_repository.dart';
import 'package:onlyveyou/repositories/search_repositories/suggestion_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SuggestionRepository suggestionRepository;
  final ProductRepository productRepository;

  SearchBloc({
    required this.suggestionRepository,
    required this.productRepository,
  }) : super(SearchInitialState()) {
    on<TextChangedEvent>(_onTextChangedEvent,
        transformer: debounce(const Duration(milliseconds: 300)));

    on<ShowResultEvent>(_onShowResultEvent);
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
      emit(SearchSuggestionState(suggestions));
    } catch (error) {
      emit(
        error is SearchErrorState
            ? SearchErrorState(error.message)
            : const SearchErrorState('something went wrong'),
      );
    }
  }

  Future<void> _onShowResultEvent(
      ShowResultEvent event, Emitter<SearchState> emit) async {
    final searchTerm = event.text;

    if (searchTerm.isEmpty) {
      return emit(SearchInitialState());
    }

    emit(SearchLoadingState());
    try {
      final results = await productRepository.search(searchTerm);
      emit(SearchResultState(results));
    } catch (error) {
      emit(
        error is SearchErrorState
            ? SearchErrorState(error.message)
            : const SearchErrorState('something went wrong'),
      );
    }
  }
}
