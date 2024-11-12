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
    on<IncrementPopularity>(_onIncrementPopularity);
  }

// 로컬에 저장한 후 검색함
  Future<void> _onFetchSearchSuggestions(
    FetchSearchSuggestions event,
    Emitter<SearchSuggestionState> emit,
  ) async {
    emit(SearchSuggestionLoading());
    try {
      final sanitizedText = event.query.replaceAll(
          RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ''); // 특수문자 제거
      await Future.delayed(const Duration(seconds: 1));
      final suggestions = await suggestionRepository.searchLocal(sanitizedText);
      emit(SearchSuggestionLoaded(suggestions));
    } catch (e) {
      emit(const SearchSuggestionError('Failed to fetch suggestions'));
    }
  }

  Future<void> _onIncrementPopularity(
    IncrementPopularity event,
    Emitter<SearchSuggestionState> emit,
  ) async {
    try {
      await suggestionRepository.incrementPopularity(
          event.term, event.currentPopularity);
    } catch (e) {
      emit(const SearchSuggestionError('Failed to increment popularity'));
    }
  }
}
