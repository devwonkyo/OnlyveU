part of 'search_navigation_bloc.dart';

sealed class SearchNavigationEvent extends Equatable {
  const SearchNavigationEvent();

  @override
  List<Object> get props => [];
}

final class ChangeSearchStatusEvent extends SearchNavigationEvent {
  final SearchStatus newSearchStatus;
  const ChangeSearchStatusEvent({required this.newSearchStatus});

  @override
  List<Object> get props => [newSearchStatus];
}
