part of 'search_navigation_bloc.dart';

enum SearchStatus {
  initial,
  searching,
  complete,
}

sealed class SearchNavigationState extends Equatable {
  final SearchStatus searchStatus;
  const SearchNavigationState({required this.searchStatus});

  @override
  List<Object> get props => [];
}

final class SearchNavigationInitial extends SearchNavigationState {
  const SearchNavigationInitial() : super(searchStatus: SearchStatus.initial);
}

final class SearchNavigationSelected extends SearchNavigationState {
  final SearchStatus selectedSearchStatus;
  const SearchNavigationSelected({required this.selectedSearchStatus})
      : super(searchStatus: selectedSearchStatus);
}
