part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

final class TextChangedEvent extends SearchEvent {
  final String text;

  const TextChangedEvent({
    required this.text,
  });

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'TextChangedEvent(text: $text)';
}

class ShowResultEvent extends SearchEvent {
  final String text;
  const ShowResultEvent({required this.text});

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'ShowResultEvent(text: $text)';
}
