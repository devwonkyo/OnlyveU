part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

final class SearchInitial extends SearchState {}

final class Searching extends SearchState {}

class SearchComplete extends SearchState {
  final List<String> results;

  const SearchComplete(this.results);
}
