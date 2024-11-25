abstract class RecentSearchRepository {
  Future<List<String>> loadRecentSearches();
  Future<void> addSearchTerm(String term);
  Future<void> removeSearchTerm(String term);
  Future<void> clearAllSearchTerms();
}
