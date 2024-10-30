part of 'product_search_cubit.dart';

class ProductSearchState extends Equatable {
  final String searchTerm;
  const ProductSearchState({
    required this.searchTerm,
  });

  factory ProductSearchState.initial() {
    return const ProductSearchState(searchTerm: '');
  }

  @override
  List<Object> get props => [searchTerm];

  @override
  String toString() => 'SearchTermState(searchTerm: $searchTerm)';

  ProductSearchState copyWith({
    String? searchTerm,
  }) {
    return ProductSearchState(
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}
