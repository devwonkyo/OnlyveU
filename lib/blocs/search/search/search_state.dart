part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

final class SearchInitialState extends SearchState {}

final class SearchSuggestionsState extends SearchState {
  final List<SuggestionModel> suggestions;

  const SearchSuggestionsState(this.suggestions);

  @override
  List<Object> get props => [suggestions];

  @override
  String toString() => 'SearchSuggestionsState(suggestions: $suggestions)';
}

final class SearchResultState extends SearchState {
  final List<ProductModel> results;

  const SearchResultState(this.results);

  @override
  List<Object> get props => [results];

  @override
  String toString() => 'SearchResultState(results: $results)';
}

final class SearchErrorState extends SearchState {
  final String message;

  const SearchErrorState(this.message);

  @override
  List<Object> get props => [message];
}
