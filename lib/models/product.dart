// import 'package:cloud_firestore/cloud_firestore.dart';
//
// // Product 클래스는 Firestore에서 가져온 화장품 상품 정보를 관리하는 모델 클래스입니다.
// class Product {
//   final String id;             // Firestore 문서 ID (상품 고유 ID)
//   final String name;           // 상품 이름
//   final String description;     // 상품 설명
//   final double price;           // 상품 가격
//   final int stock;              // 남은 재고 수량
//   final String category;        // 상품 카테고리 (예: 스킨케어, 메이크업 등)
//   final double rating;          // 상품 평점
//   final int reviewCount;        // 상품에 대한 리뷰 수
//   final String imageUrl;        // 상품 이미지 URL
//   final bool isPopular;         // 인기 상품 여부 (기본값: false)
//   final bool isRecommended;     // 추천 상품 여부 (기본값: false)
//
//   // Product 생성자
//   Product({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.stock,
//     required this.category,
//     required this.rating,
//     required this.reviewCount,
//     required this.imageUrl,
//     this.isPopular = false,
//     this.isRecommended = false,
//   });
//
//   // Firestore 데이터에서 Product 모델로 변환하는 팩토리 메서드
//   factory Product.fromFirestore(DocumentSnapshot doc) {
//     // Firestore 문서 데이터를 Map 형식으로 가져옴
//     Map data = doc.data() as Map<String, dynamic>;
//     return Product(
//       id: doc.id, // 문서 ID를 Product의 id 필드로 설정
//       name: data['name'] ?? '', // 상품 이름, 없을 경우 빈 문자열로 초기화
//       description: data['description'] ?? '', // 상품 설명, 없을 경우 빈 문자열로 초기화
//       price: data['price']?.toDouble() ?? 0.0, // 상품 가격, 없을 경우 0.0으로 초기화
//       stock: data['stock'] ?? 0, // 재고 수량, 없을 경우 0으로 초기화
//       category: data['category'] ?? '', // 카테고리, 없을 경우 빈 문자열로 초기화
//       rating: data['rating']?.toDouble() ?? 0.0, // 평점, 없을 경우 0.0으로 초기화
//       reviewCount: data['reviewCount'] ?? 0, // 리뷰 수, 없을 경우 0으로 초기화
//       imageUrl: data['imageUrl'] ?? '', // 이미지 URL, 없을 경우 빈 문자열로 초기화
//       isPopular: data['isPopular'] ?? false, // 인기 상품 여부, 기본값 false
//       isRecommended: data['isRecommended'] ?? false, // 추천 상품 여부, 기본값 false
//     );
//   }
// }
