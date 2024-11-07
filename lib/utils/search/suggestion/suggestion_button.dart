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
  const CategorySuggestionUpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// 파이어베이스의 products에서 brandName의 값을 SuggestionModel 형식으로 suggestions 컬랙션에 추가하고싶어