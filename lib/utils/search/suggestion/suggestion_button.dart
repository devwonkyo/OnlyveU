import 'package:flutter/material.dart';

import 'suggestion_service.dart';

class BrandSuggestionUpdateButton extends StatelessWidget {
  final SuggestionService suggestionService = SuggestionService();

  BrandSuggestionUpdateButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await suggestionService.addBrandNamesToSuggestions();
      },
      child: const Text('Update Brand Suggestions'),
    );
  }
}

class CategorySuggestionUpdateButton extends StatelessWidget {
  final SuggestionService suggestionService = SuggestionService();
  CategorySuggestionUpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await suggestionService.addCategoriesToSuggestions();
      },
      child: const Text('Update Category Suggestions'),
    );
  }
}

// class DeleteTrendScoreButton extends StatelessWidget {
//   final SuggestionService suggestionService = SuggestionService();
//   DeleteTrendScoreButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () async {
//         await suggestionService.deleteTrendScoreField();
//       },
//       child: const Text('Delete Trend Score Suggestions'),
//     );
//   }
// }
