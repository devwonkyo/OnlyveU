import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/search_models/search_models.dart';

class TrendUpdater {
  final TrendCalculator trendCalculator;
  final FirebaseFirestore _firestore;

  TrendUpdater({required this.trendCalculator, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  void startUpdating() {
    Timer.periodic(const Duration(minutes: 10), (timer) async {
      await updateTrendScores();
    });
  }

  Future<void> updateTrendScores() async {
    final querySnapshot = await _firestore.collection('suggestions').get();

    for (final doc in querySnapshot.docs) {
      final suggestion = SuggestionModel.fromFirestore(doc);
      final trendScore =
          await trendCalculator.calculateTrendScore(suggestion.term);

      final updatedSuggestion = SuggestionModel(
        term: suggestion.term,
        popularity: suggestion.popularity,
        trendScore: trendScore,
      );

      await _firestore
          .collection('suggestions')
          .doc(suggestion.term)
          .set(updatedSuggestion.toFirestore());
    }
  }
}
