class SuggestionEntity {
  final String term;
  final int popularity;
  final String sourceCollection;

  SuggestionEntity({
    required this.term,
    required this.popularity,
    required this.sourceCollection,
  });
}
