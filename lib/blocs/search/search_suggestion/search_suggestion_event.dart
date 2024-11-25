part of 'search_suggestion_bloc.dart';

sealed class SearchSuggestionEvent extends Equatable {
  const SearchSuggestionEvent();

  @override
  List<Object> get props => [];
}

final class FetchSearchSuggestions extends SearchSuggestionEvent {
  final String query;

  const FetchSearchSuggestions(this.query);

  @override
  List<Object> get props => [query];
}

final class IncrementPopularity extends SearchSuggestionEvent {
  final String term;
  final int currentPopularity;

  const IncrementPopularity(this.term, this.currentPopularity);
}
