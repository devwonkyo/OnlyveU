import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/search_models/search_models.dart';

class SuggestionService {
  final FirebaseFirestore _firestore;

  SuggestionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addBrandNamesToSuggestions() async {
    try {
      // Firestore에서 products 컬렉션의 모든 문서를 가져옵니다.
      final querySnapshot = await _firestore.collection('products').get();

      // 각 문서에서 brandName 값을 추출하고 SuggestionModel 형식으로 변환합니다.
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        var brandName = data['brandName'] as String?;

        if (brandName != null && brandName.isNotEmpty) {
          // brandName 값에서 대괄호를 제거합니다.
          brandName = brandName.replaceAll('[', '').replaceAll(']', '');

          // Firestore에서 이미 존재하는 문서를 확인합니다.
          final existingDoc =
              await _firestore.collection('suggestions').doc(brandName).get();

          if (!existingDoc.exists) {
            final suggestion = SuggestionModel(
              term: brandName,
              popularity: 0,
              sourceCollection: 'brandName', // sourceCollection 필드 설정
            );

            // 변환된 SuggestionModel 객체를 suggestions 컬렉션에 추가합니다.
            await _firestore
                .collection('suggestions')
                .doc(suggestion.term)
                .set(suggestion.toMap());
          }
        }
      }

      print('Brand names added to suggestions successfully.');
    } catch (e) {
      print('Error adding brand names to suggestions: $e');
    }
  }

  Future<void> addCategoriesToSuggestions() async {
    try {
      // categories 컬렉션의 모든 문서를 가져옴
      QuerySnapshot categoriesSnapshot =
          await _firestore.collection('categories').get();

      for (QueryDocumentSnapshot categoryDoc in categoriesSnapshot.docs) {
        String name = categoryDoc.get('name');
        List<dynamic> subcategories = categoryDoc.get('subcategories');

        // 각 카테고리와 서브카테고리를 SuggestionModel로 변환하여 suggestions 컬렉션에 추가
        await _addSuggestionIfNotExists(name, 'category');

        for (var subcategory in subcategories) {
          if (subcategory is Map<String, dynamic> &&
              subcategory.containsKey('name')) {
            String subcategoryName = subcategory['name'];
            if (subcategoryName.contains('/')) {
              List<String> subcategoryParts = subcategoryName.split('/');
              for (String part in subcategoryParts) {
                await _addSuggestionIfNotExists(part.trim(), 'subcategory');
              }
            } else {
              await _addSuggestionIfNotExists(subcategoryName, 'subcategory');
            }
          } else {
            print('Invalid subcategory type: $subcategory');
          }
        }
      }

      print('Categories and subcategories added to suggestions successfully.');
    } catch (e) {
      print('Error adding categories and subcategories to suggestions: $e');
    }
  }

  Future<void> _addSuggestionIfNotExists(
      String term, String sourceCollection) async {
    DocumentSnapshot suggestionDoc =
        await _firestore.collection('suggestions').doc(term).get();

    if (!suggestionDoc.exists) {
      SuggestionModel suggestion = SuggestionModel(
        term: term,
        popularity: 0,
        sourceCollection: sourceCollection,
      );

      await _firestore
          .collection('suggestions')
          .doc(suggestion.term)
          .set(suggestion.toMap());
    }
  }

  Future<void> deleteTrendScoreField() async {
    try {
      final querySnapshot = await _firestore.collection('suggestions').get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          'trendScore': FieldValue.delete(),
        });
      }
      print('trendScore field deleted successfully');
    } catch (e) {
      print('Error deleting trendScore field: $e');
    }
  }
}
