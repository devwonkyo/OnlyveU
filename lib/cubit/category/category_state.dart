part of 'category_cubit.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final int selectedIndex;
  CategoryLoaded(this.categories,{this.selectedIndex = 0});
}
class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}