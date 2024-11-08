part of 'recent_search_bloc.dart';

sealed class RecentSearchState extends Equatable {
  const RecentSearchState();

  @override
  List<Object> get props => [];
}

final class RecentSearchInitial extends RecentSearchState {}

final class RecentSearchEmpty extends RecentSearchState {}

final class RecentSearchLoading extends RecentSearchState {}

final class RecentSearchLoaded extends RecentSearchState {
  final List<String> recentSearches;

  const RecentSearchLoaded(this.recentSearches);
}

final class RecentSearchError extends RecentSearchState {
  final String message;

  const RecentSearchError(this.message);

  @override
  List<Object> get props => [message];
}
