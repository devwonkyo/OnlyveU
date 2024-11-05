import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/search_models/search_models.dart';

import 'suggestion_repository.dart';

class SuggestionRepositoryImpl implements SuggestionRepository {
  final FirebaseFirestore _firestore;

  SuggestionRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<SuggestionModel>> search(String term) async {
    final querySnapshot = await _firestore
        .collection('suggestions')
        .where('term', isGreaterThanOrEqualTo: term)
        .where('term', isLessThanOrEqualTo: '$term\uf8ff')
        .orderBy('term')
        .orderBy('popularity', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => SuggestionModel.fromFirestore(doc))
        .toList();
  }
}
