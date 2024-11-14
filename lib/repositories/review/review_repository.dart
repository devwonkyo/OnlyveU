import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/review_model.dart';

class ReviewRepository{
  final FirebaseFirestore _firestore;

  ReviewRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ReviewModel>> findProductReview(String productId) async {

    return [];
  }
}