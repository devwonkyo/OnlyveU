part of 'tag_search_cubit.dart';

class TagSearchState extends Equatable {
  final String searchTerm;
  const TagSearchState({
    required this.searchTerm,
  });

  factory TagSearchState.initial() {
    return const TagSearchState(searchTerm: '');
  }

  @override
  List<Object> get props => [searchTerm];

  @override
  String toString() => 'TagSearchState(searchTerm: $searchTerm)';

  TagSearchState copyWith({
    String? searchTerm,
  }) {
    return TagSearchState(
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}
