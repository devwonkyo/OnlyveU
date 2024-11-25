import 'package:bloc/bloc.dart';
import 'package:onlyveyou/models/category_model.dart';
import 'package:onlyveyou/repositories/category_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepository;
  List<Category> categories = [];
  int selectedIndex = 0;

  CategoryCubit({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository,
        super(CategoryInitial());

  void selectCategory(int index) {
    selectedIndex = index;
    emit(CategoryLoaded(categories, selectedIndex: selectedIndex));
  }

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    try {
      categories = await _categoryRepository.fetchCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}