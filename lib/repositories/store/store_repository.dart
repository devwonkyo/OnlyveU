import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/store_model.dart';

class StoreRepository {
  final FirebaseFirestore _firestore;

  StoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<StoreModel>> getAllStores() async {
    try {
      // Replace 'store' with your Firestore collection name
      final snapshot = await _firestore.collection('stores').get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming that the store data is structured as per StoreModel
        return snapshot.docs
            .map((doc) => StoreModel.fromMap(doc.data()))
            .toList();
      } else {
        throw Exception('No store data available');
      }
    } catch (e) {
      throw Exception('Failed to fetch store data: $e');
    }
  }
}
