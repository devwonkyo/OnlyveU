part of 'recent_search_bloc.dart';

sealed class RecentSearchEvent extends Equatable {
  const RecentSearchEvent();

  @override
  List<Object> get props => [];
}

final class AddSearchTerm extends RecentSearchEvent {
  final String term;

  const AddSearchTerm(this.term);

  @override
  List<Object> get props => [term];
}

final class LoadRecentSearches extends RecentSearchEvent {}

final class RemoveSearchTerm extends RecentSearchEvent {
  final String term;

  const RemoveSearchTerm(this.term);

  @override
  List<Object> get props => [term];
}
