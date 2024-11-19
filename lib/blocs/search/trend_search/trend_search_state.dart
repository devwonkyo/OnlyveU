part of 'trend_search_bloc.dart';

sealed class TrendSearchState extends Equatable {
  const TrendSearchState();

  @override
  List<Object> get props => [];
}

final class TrendSearchInitial extends TrendSearchState {}

final class TrendSearchLoading extends TrendSearchState {}

final class TrendSearchLoaded extends TrendSearchState {
  final List<SuggestionModel> trendSearches;
  final String updateTime;

  const TrendSearchLoaded(this.trendSearches, this.updateTime);
}

final class TrendSearchError extends TrendSearchState {
  final String message;

  const TrendSearchError(this.message);

  @override
  List<Object> get props => [message];
}
