import 'package:onlyveyou/models/category_model.dart';

class CategorySelection{
  final Category category;              // 선택한 대분류 카테고리
  final String? selectedSubcategoryId;  // 선택된 소분류 카테고리 ID (선택적)

  CategorySelection({
    required this.category,
    this.selectedSubcategoryId,
  });
}