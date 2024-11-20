import 'package:fpdart/fpdart.dart';

abstract interface class SuggestionRepository {
  Future<Either<String, String>> getSuggestionByTerm({required String term});
}
