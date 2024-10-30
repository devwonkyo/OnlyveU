import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/category_model.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final FirebaseFirestore _firestore;
  List<Category> categories = [];
  int selectedIndex = 0;

  CategoryCubit({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(CategoryInitial());

  void selectCategory(int index) {
    selectedIndex = index;
    emit(CategoryLoaded(categories, selectedIndex: selectedIndex));
  }

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('id') // id 기준으로 오름차순 정렬
          .get();

      categories = snapshot.docs
          .map((doc) => Category.fromFirestore(doc.data()))
          .toList();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}