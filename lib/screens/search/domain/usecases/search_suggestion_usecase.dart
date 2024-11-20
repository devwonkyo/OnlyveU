import 'package:fpdart/fpdart.dart';

import '../repositories/suggestion_repository.dart';

class SearchSuggestionsUsecase {
  final SuggestionRepository repo;

  SearchSuggestionsUsecase({required this.repo});

  Future<Either<String, String>> call({required String term}) async {
    return await repo.getSuggestionByTerm(term: term);
  }
}
