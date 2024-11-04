import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/dummy_data.dart';

class FirebaseDataUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 더미 데이터를 Firestore에 업로드하는 함수
  Future<void> uploadDummyProducts() async {
    try {
      // 컬렉션 레퍼런스 생성
      final CollectionReference productsRef = _firestore.collection('products');

      // 더미 데이터 생성
      final List<ProductModel> dummyProducts = generateDummyProducts();

      // 배치 작업 시작
      WriteBatch batch = _firestore.batch();
      int operationCount = 0;

      for (var product in dummyProducts) {
        // product.productId를 문서 ID로 사용
        DocumentReference docRef = productsRef.doc(product.productId);

        // Firestore에 저장할 데이터 준비
        Map<String, dynamic> productData = {
          'name': product.name,
          'brandName': product.brandName,
          'productImageList': product.productImageList,
          'descriptionImageList': product.descriptionImageList,
          'price': product.price,
          'discountPercent': product.discountPercent,
          'categoryId': product.categoryId,
          'subcategoryId': product.subcategoryId,
          'favoriteList': product.favoriteList,
          'reviewList': product.reviewList,
          'tagList': product.tagList,
          'cartList': [], // 초기에는 빈 배열
          'visitCount': product.visitCount,
          'rating': product.rating,
          'registrationDate': Timestamp.fromDate(product.registrationDate),
          'salesVolume': product.salesVolume,
          'isBest': product.isBest,
          'isPopular': product.isPopular,
        };

        // 배치에 작업 추가
        batch.set(docRef, productData);
        operationCount++;

        // Firestore 배치 작업 제한(500)에 도달하면 커밋
        if (operationCount >= 500) {
          await batch.commit();
          batch = _firestore.batch(); // 새로운 배치 시작
          operationCount = 0;
        }
      }

      // 남은 작업이 있다면 최종 커밋
      if (operationCount > 0) {
        await batch.commit();
      }

      print(
          'Successfully uploaded ${dummyProducts.length} products to Firestore');
    } catch (e) {
      print('Error uploading dummy data: $e');
      throw e;
    }
  }

  /// 기존 제품 데이터를 모두 삭제하는 함수
  Future<void> clearExistingProducts() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('products').get();

      WriteBatch batch = _firestore.batch();
      int operationCount = 0;

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        operationCount++;

        if (operationCount >= 500) {
          await batch.commit();
          batch = _firestore.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      print('Successfully cleared existing products');
    } catch (e) {
      print('Error clearing existing products: $e');
      throw e;
    }
  }

  /// 데이터 초기화 및 업로드를 실행하는 메인 함수
  Future<void> initializeDatabase() async {
    try {
      print('Starting database initialization...');

      // 기존 데이터 삭제
      await clearExistingProducts();

      // 새 데이터 업로드
      await uploadDummyProducts();

      print('Database initialization completed successfully');
    } catch (e) {
      print('Error initializing database: $e');
      throw e;
    }
  }
}
