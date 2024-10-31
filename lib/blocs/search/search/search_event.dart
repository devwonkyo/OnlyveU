part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

final class StartSearch extends SearchEvent {
  final String searchTerm;

  const StartSearch(this.searchTerm);
}

final class CompleteSearch extends SearchEvent {
  final List<String> results;

  const CompleteSearch(this.results);
}
