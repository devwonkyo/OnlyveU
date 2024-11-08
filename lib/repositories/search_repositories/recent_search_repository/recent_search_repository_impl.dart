import 'package:shared_preferences/shared_preferences.dart';
import 'recent_search_repository.dart';

class RecentSearchRepositoryImpl implements RecentSearchRepository {
  static const String _key = 'recentSearches';

  @override
  Future<List<String>> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  @override
  Future<void> addSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearches = prefs.getStringList(_key) ?? [];

    recentSearches.remove(term);
    recentSearches.insert(0, term);
    if (recentSearches.length > 20) {
      recentSearches.removeLast();
    }

    await prefs.setStringList(_key, recentSearches);
  }

  @override
  Future<void> removeSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearches = prefs.getStringList(_key) ?? [];

    recentSearches.remove(term);

    await prefs.setStringList(_key, recentSearches);
  }
}
