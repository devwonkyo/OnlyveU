import 'package:fpdart/fpdart.dart';

abstract interface class RecentSearchRepository {
  // 최근 검색어
  Future<Either<String, String>> getRecentSearches();
  Future<Either<String, String>> addRecentSearch({required String term});
  Future<Either<String, String>> deleteRecentSearch({required int index});
  Future<Either<String, String>> deleteAllRecentSearches();
}
