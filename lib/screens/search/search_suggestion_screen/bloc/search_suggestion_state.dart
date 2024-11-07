part of 'search_suggestion_bloc.dart';

sealed class SearchSuggestionState extends Equatable {
  const SearchSuggestionState();

  @override
  List<Object> get props => [];
}

final class SearchSuggestionInitial extends SearchSuggestionState {}

final class SearchSuggestionLoading extends SearchSuggestionState {}

final class SearchSuggestionLoaded extends SearchSuggestionState {
  final List<SuggestionModel> suggestions;

  const SearchSuggestionLoaded(this.suggestions);

  @override
  List<Object> get props => [suggestions];
}

final class SearchSuggestionError extends SearchSuggestionState {
  final String message;

  const SearchSuggestionError(this.message);

  @override
  List<Object> get props => [message];
}
