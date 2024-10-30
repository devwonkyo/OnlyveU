// // Firestore와 상호작용을 통해 상품 데이터를 가져오는 리포지토리 클래스
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../models/product.dart';
//
// class ProductRepository {
//   // Firebase Firestore 인스턴스 생성
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Firestore에서 인기 상품 목록 가져오기
//   // isPopular 필드가 true로 설정된 상품만 필터링하여 실시간으로 가져옴
//   Stream<List<Product>> fetchPopularProducts() {
//     return _firestore
//         .collection('products') // 'products' 컬렉션 참조
//         .where('isPopular', isEqualTo: true) // isPopular 필터 적용
//         .snapshots() // 실시간 데이터 스트림 가져오기
//         .map((snapshot) => // 쿼리 결과를 Product 모델 리스트로 매핑
//             snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
//   }
//
//   // Firestore에서 추천 상품 목록 가져오기
//   // isRecommended 필드가 true로 설정된 상품만 필터링하여 실시간으로 가져옴
//   Stream<List<Product>> fetchRecommendedProducts() {
//     return _firestore
//         .collection('products') // 'products' 컬렉션 참조
//         .where('isRecommended', isEqualTo: true) // isRecommended 필터 적용
//         .snapshots() // 실시간 데이터 스트림 가져오기
//         .map((snapshot) => // 쿼리 결과를 Product 모델 리스트로 매핑
//             snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
//   }
//
//   // Firestore에서 단일 상품의 상세 데이터 가져오기
//   // 상품 ID를 기반으로 해당 상품의 상세 데이터를 한 번만 가져옴
//   Future<Product?> fetchProductById(String productId) async {
//     final doc =
//         await _firestore.collection('products').doc(productId).get(); // 문서 참조
//     if (doc.exists) {
//       return Product.fromFirestore(doc); // 문서가 존재할 경우 Product 객체 반환
//     }
//     return null; // 문서가 존재하지 않을 경우 null 반환
//   }
// }
