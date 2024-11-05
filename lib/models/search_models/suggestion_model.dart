import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SuggestionModel extends Equatable {
  final String term;
  final int popularity;
  const SuggestionModel({
    required this.term,
    this.popularity = 0,
  });

  @override
  List<Object> get props => [term, popularity];

  @override
  String toString() => 'SuggestionModel(term: $term, popularity: $popularity)';

  factory SuggestionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return SuggestionModel(
      term: data['term'] ?? '',
      popularity: data['popularity'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'term': term,
      'popularity': popularity,
    };
  }
}
