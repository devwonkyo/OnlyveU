part of 'trend_search_bloc.dart';

sealed class TrendSearchEvent extends Equatable {
  const TrendSearchEvent();

  @override
  List<Object> get props => [];
}

final class AddSearchHistory extends TrendSearchEvent {
  final String term;
  final int currentTrendScore;

  const AddSearchHistory(this.term, this.currentTrendScore);
}

final class LoadTrendSearch extends TrendSearchEvent {}
