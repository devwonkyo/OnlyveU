import 'dart:math';

import 'package:onlyveyou/models/product_model.dart';

List<ProductModel> generateDummyProducts() {
  final random = Random();

  final List<String> brands = [
    '설화수',
    '헤라',
    '이니스프리',
    '라네즈',
    '에뛰드하우스',
    'SK-II',
    '시세이도',
    '랑콤',
    '에스티 로더',
    '비오템'
  ];

  final List<String> categories = [
    '1', // 스킨케어
    '2', // 메이크업
    '3', // 향수/바디
    '4', // 헤어케어
    '5' // 선케어
  ];

  final Map<String, List<String>> subcategories = {
    '1': ['1_1', '1_2', '1_3'], // 스킨/로션/크림
    '2': ['2_1', '2_2', '2_3'], // 베이스/아이/립
    '3': ['3_1', '3_2', '3_3'], // 향수/바디워시/로션
    '4': ['4_1', '4_2', '4_3'], // 샴푸/트리트먼트/스타일링
    '5': ['5_1', '5_2', '5_3'] // 선크림/선스프레이/선스틱
  };

  final List<String> tags = [
    'TAG001', // 수분
    'TAG002', // 미백
    'TAG003', // 주름개선
    'TAG004', // 진정
    'TAG005', // 모공케어
    'TAG006', // 자외선차단
    'TAG007', // 항산화
    'TAG008' // 보습
  ];

  List<ProductModel> products = [];

  for (int i = 1; i <= 50; i++) {
    String categoryId = categories[i % categories.length];
    List<String> subCats = subcategories[categoryId] ?? [];
    String subcategoryId = subCats[i % subCats.length];

    String brand = brands[i % brands.length];

    // 가격은 10000원 ~ 300000원 사이
    int basePrice = 10000 + (i * 7000);

    // 제품 이름 생성
    String productName = _generateProductName(brand, categoryId, i);

    products.add(ProductModel(
      productId: 'PROD${i.toString().padLeft(3, '0')}',
      name: productName,
      brandName: brand,
      productImageList: [
        'https://example.com/images/product$i/1.jpg',
        'https://example.com/images/product$i/2.jpg',
        'https://example.com/images/product$i/3.jpg'
      ],
      descriptionImageList: [
        'https://example.com/images/product$i/desc1.jpg',
        'https://example.com/images/product$i/desc2.jpg'
      ],
      price: basePrice.toString(),
      discountPercent: (i % 5) * 5, // 0%, 5%, 10%, 15%, 20% 할인
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      favoriteList: [], // 초기에는 빈 리스트
      reviewList: [], // 초기에는 빈 리스트
      tagList: _generateRandomTags(tags, random),
      cartList: [], // 초기에는 빈 리스트
      visitCount: 100 + (i * 10), // 기본 100회 방문에 추가 방문수
      rating: 3.5 + (random.nextDouble() * 1.5), // 3.5~5.0 사이 평점
      registrationDate:
          DateTime.now().subtract(Duration(days: i * 2)), // 2일 간격으로 등록일 설정
      salesVolume: 50 + (random.nextInt(200)), // 50~250 사이 판매량
      isBest: false, // 기본값 false로 설정
      isPopular: false, // 기본값 false로 설정
    ));
  }

  return products;
}

String _generateProductName(String brand, String categoryId, int index) {
  final Map<String, List<String>> productTypes = {
    '1': ['수분 크림', '에센스', '토너', '앰플', '로션'],
    '2': ['파운데이션', '립스틱', '아이섀도우', '마스카라', '컨실러'],
    '3': ['바디로션', '바디워시', '향수', '핸드크림', '바디미스트'],
    '4': ['샴푸', '트리트먼트', '헤어에센스', '헤어오일', '스케일링'],
    '5': ['선크림', '선스프레이', '선스틱', '선쿠션', '선젤']
  };

  final List<String> prefixes = ['프리미엄', '인텐시브', '퍼펙트', '어드밴스드', '리얼'];
  final List<String> suffixes = ['EX', 'PRO', 'PLUS', 'S', 'N'];

  List<String> types = productTypes[categoryId] ?? productTypes['1']!;
  String type = types[index % types.length];
  String prefix = prefixes[index % prefixes.length];
  String suffix = suffixes[index % suffixes.length];

  return '$prefix ${type} $suffix';
}

List<String> _generateRandomTags(List<String> allTags, Random random) {
  final int tagCount = random.nextInt(3) + 1; // 1~3개의 태그 선택
  final List<String> selectedTags = List.from(allTags)..shuffle(random);
  return selectedTags.take(tagCount).toList();
}
