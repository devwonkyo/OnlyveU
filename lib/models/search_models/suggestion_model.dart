import 'package:equatable/equatable.dart';

class SuggestionModel extends Equatable {
  final String term;
  final int popularity;
  final String sourceCollection;

  const SuggestionModel({
    required this.term,
    this.popularity = 0,
    this.sourceCollection = '',
  });

  @override
  List<Object> get props => [term, popularity, sourceCollection];

  @override
  String toString() =>
      'SuggestionModel(term: $term, popularity: $popularity,sourceCollection: $sourceCollection)';

  factory SuggestionModel.fromMap(Map<String, dynamic> map) {
    return SuggestionModel(
      term: map['term'] ?? '',
      popularity: map['popularity'] ?? 0,
      sourceCollection: map['sourceCollection'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'term': term,
      'popularity': popularity,
      'sourceCollection': sourceCollection,
    };
  }
}
