import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:onlyveyou/models/search_models/search_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        .map((doc) => SuggestionModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> fetchAndStoreAllSuggestions() async {
    try {
      final querySnapshot = await _firestore.collection('suggestions').get();
      final suggestions = querySnapshot.docs
          .map((doc) => SuggestionModel.fromMap(doc.data()))
          .toList();

      await _clearStoredSuggestions();
      await _storeSuggestionsLocally(suggestions);
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
    }
  }

  Future<void> _clearStoredSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('suggestions');
    } catch (e) {
      debugPrint('Error clearing stored suggestions: $e');
    }
  }

  Future<void> _storeSuggestionsLocally(
      List<SuggestionModel> suggestions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final suggestionJson =
          suggestions.map((suggestion) => suggestion.toMap()).toList();
      final suggestionString = jsonEncode(suggestionJson);
      await prefs.setString('suggestions', suggestionString);
    } catch (e) {
      debugPrint('Error storing suggestions locally: $e');
    }
  }

  @override
  Future<List<SuggestionModel>> getStoredSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final suggestionString = prefs.getString('suggestions');
      if (suggestionString != null) {
        final List<dynamic> suggestionJson = jsonDecode(suggestionString);
        return suggestionJson
            .map((json) => SuggestionModel.fromMap(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting stored suggestions: $e');
    }
    return [];
  }

  @override
  Future<List<SuggestionModel>> searchLocal(String term) async {
    final storedSuggestions = await getStoredSuggestions();
    if (term.isNotEmpty) {
      final lowerCaseTerm = term.toLowerCase();
      return storedSuggestions.where((suggestion) {
        return suggestion.term.toLowerCase().contains(lowerCaseTerm);
      }).toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> incrementPopularity(String term, int currentPopularity) async {
    try {
      final querySnapshot = await _firestore
          .collection('suggestions')
          .where('term', isEqualTo: term)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final suggestionRef = querySnapshot.docs.first.reference;
        await suggestionRef.update({
          'popularity': currentPopularity + 1,
        });
      }
    } catch (e) {
      debugPrint('Error incrementing popularity: $e');
    }
  }

  @override
  Future<List<SuggestionModel>> getTrendSearches() async {
    final querySnapshot = await _firestore
        .collection('suggestions')
        .orderBy('popularity', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs
        .map((doc) => SuggestionModel.fromMap(doc.data()))
        .toList();
  }
}
