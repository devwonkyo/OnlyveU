part of 'search_result_bloc.dart';

sealed class SearchResultState extends Equatable {
  const SearchResultState();

  @override
  List<Object> get props => [];
}

final class SearchResultInitial extends SearchResultState {}

final class SearchResultEmpty extends SearchResultState {}

final class SearchResultLoading extends SearchResultState {}

final class SearchResultLoaded extends SearchResultState {
  final List<ProductModel> products;

  const SearchResultLoaded(this.products);

  @override
  List<Object> get props => [products];
}

final class SearchResultError extends SearchResultState {
  final String message;

  const SearchResultError(this.message);

  @override
  List<Object> get props => [message];
}
