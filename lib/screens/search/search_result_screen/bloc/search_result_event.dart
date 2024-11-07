part of 'search_result_bloc.dart';

sealed class SearchResultEvent extends Equatable {
  const SearchResultEvent();

  @override
  List<Object> get props => [];
}

final class FetchSearchResults extends SearchResultEvent {
  final String query;

  const FetchSearchResults(this.query);

  @override
  List<Object> get props => [query];
}
