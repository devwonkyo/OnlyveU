part of 'search_view_bloc.dart';

sealed class SearchViewEvent extends Equatable {
  const SearchViewEvent();

  @override
  List<Object> get props => [];
}

final class ChangeView extends SearchViewEvent {
  final SearchTextFieldStatus newStatus;

  const ChangeView({required this.newStatus});
}
