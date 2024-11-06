part of 'search_text_field_bloc.dart';

sealed class SearchTextFieldEvent extends Equatable {
  const SearchTextFieldEvent();

  @override
  List<Object> get props => [];
}

final class TextChanged extends SearchTextFieldEvent {
  final String text;

  const TextChanged(this.text);

  @override
  List<Object> get props => [text];
}

final class TextSubmitted extends SearchTextFieldEvent {
  final String text;

  const TextSubmitted(this.text);

  @override
  List<Object> get props => [text];
}

final class TextDeleted extends SearchTextFieldEvent {}
