import 'package:shared_preferences/shared_preferences.dart';

class SearchService {
  static const _recentSearchesKey = 'recentSearches';

  Future<void> saveRecentSearch(String searchTerm) async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    recentSearches.remove(searchTerm);
    recentSearches.add(searchTerm);
    await prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  Future<List<String>> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey) ?? [];
  }

  Future<void> removeRecentSearch(String searchTerm) async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    recentSearches.remove(searchTerm);
    await prefs.setStringList(_recentSearchesKey, recentSearches);
  }
}
