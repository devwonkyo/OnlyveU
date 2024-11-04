part of 'search_text_field_bloc.dart';

sealed class SearchTextFieldState extends Equatable {
  const SearchTextFieldState();

  @override
  List<Object> get props => [];
}

final class Empty extends SearchTextFieldState {}

final class Typing extends SearchTextFieldState {}

final class Submitted extends SearchTextFieldState {}
