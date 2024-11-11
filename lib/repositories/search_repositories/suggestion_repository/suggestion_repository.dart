import 'package:onlyveyou/models/search_models/search_models.dart';

abstract class SuggestionRepository {
  Future<List<SuggestionModel>> search(String term);
  Future<void> fetchAndStoreAllSuggestions();
  Future<List<SuggestionModel>> getStoredSuggestions();
  Future<List<SuggestionModel>> searchLocal(String term);
}
