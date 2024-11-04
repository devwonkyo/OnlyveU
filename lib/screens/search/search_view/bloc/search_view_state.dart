part of 'search_view_bloc.dart';

sealed class SearchViewState extends Equatable {
  const SearchViewState();

  @override
  List<Object> get props => [];
}

final class Home extends SearchViewState {}

final class Suggestion extends SearchViewState {}

final class Result extends SearchViewState {}

final class Loading extends SearchViewState {}
