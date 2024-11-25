part of 'search_textfield_bloc.dart';

sealed class SearchTextFieldState extends Equatable {
  const SearchTextFieldState();

  @override
  List<Object> get props => [];
}

final class SearchTextFieldEmpty extends SearchTextFieldState {}

final class SearchTextFieldTyping extends SearchTextFieldState {
  final String text;

  const SearchTextFieldTyping(this.text);

  @override
  List<Object> get props => [text];
}

final class SearchTextFieldSubmitted extends SearchTextFieldState {
  final String text;

  const SearchTextFieldSubmitted(this.text);

  @override
  List<Object> get props => [text];
}
