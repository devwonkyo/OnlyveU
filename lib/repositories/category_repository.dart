import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/category_model.dart';


class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Category>> fetchCategories() async {
    final snapshot = await _firestore
        .collection('categories')
        .orderBy('id') // id 기준으로 오름차순 정렬
        .get();

    return snapshot.docs.map((doc) => Category.fromFirestore(doc.data())).toList();
  }



}