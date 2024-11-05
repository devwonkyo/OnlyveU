part of 'search_text_field_bloc.dart';

sealed class SearchTextFieldState extends Equatable {
  const SearchTextFieldState();

  @override
  List<Object> get props => [];
}

final class SearchTextFieldEmpty extends SearchTextFieldState {}

final class SearchTextFieldTyping extends SearchTextFieldState {
  final String text;

  const SearchTextFieldTyping(this.text);
}

final class SearchTextFieldSubmitted extends SearchTextFieldState {}
