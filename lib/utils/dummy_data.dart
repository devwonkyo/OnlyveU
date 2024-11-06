import 'dart:math';

import 'package:onlyveyou/models/product_model.dart';

List<ProductModel> generateDummyProducts() {
  final random = Random();
  final imageUrls = [
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/thumbnails/10/0000/0021/A00000021105204ko.png?l=ko&rs=644x0&sf=webp',
    'https://lh5.googleusercontent.com/proxy/q9t7C4XKDPMTmqDwCKdqhjFpzD_UFXl4DTAMOQRDSEOqHMZk7PGor-8aTsu070UAyxS12seU5IJ46dFf0tYz9YpCDP6_ayk-1aHekJSj99fZ9E3OKA',
    'https://image2.lotteimall.com/goods/08/37/84/1599843708_1.jpg/dims/resizemc/550x550/optimize',
    'https://cdn.011st.com/11dims/resize/1000x1000/quality/75/11src/product/4987324949/A1.png?253000000',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/thumbnails/10/0000/0021/A00000021111924ko.jpg?l=ko&rs=560x0&sf=webp',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/html/crop/A000000189713/202409261744/crop0/d2awjssdq42p8p.cloudfront.net/parnell/oliveyoung/PN0002-4/20240419/detail_01.jpg?created=202409261746',
    'https://image.fnnews.com/resource/media/image/2019/07/18/201907182013061215_l.jpg',
    'https://www.cosinkorea.com/data/photos/20240937/art_17258897398934_d37cc2.jpg',
    'https://image.oliveyoung.co.kr/uploads/contents/202203/03catch/mc_cont2_1.jpg',
    'https://thumbnews.nateimg.co.kr/view610///news.nateimg.co.kr/orgImg/sg/2021/06/30/20210630509930.jpg',
    'https://cdn.hitnews.co.kr/news/photo/202407/56284_75421_137.jpg',
    'https://www.economytalk.kr/news/photo/202404/253821_128501_4245.jpg',
    'https://image.oliveyoung.co.kr/uploads/images/display/90000020048/263/6174149209309348689.jpg',
    'https://gd.image-gmkt.com/%ED%97%A4%EB%9D%BC-%EB%82%A8%EC%9E%90-%EC%98%AC%EC%9D%B8%EC%9B%90-%EC%98%AC%EB%A6%AC%EB%B8%8C%EC%98%81-%EC%8A%A4%ED%82%A8-%EB%A1%9C%EC%85%98-%ED%99%94%EC%9E%A5%ED%92%88-150ML/li/122/376/2168376122.g_350-w-et-pj_g.jpg',
    'https://img.danawa.com/prod_img/500000/786/035/img/12035786_1.jpg?_v=20200812163101&shrink=360:360',
    'https://img1.newsis.com/2024/08/30/NISI20240830_0001641516_web.jpg',
    'https://thumbnail9.coupangcdn.com/thumbnails/remote/492x492ex/image/vendor_inventory/73c0/cdeb9d6707d4d833cb09f717d3d79c44ae04d6c57d18d4c38032ed755ab3.jpg',
    'https://lh4.googleusercontent.com/proxy/FJ164L1hF0AnVwfCuxD6w9fJ8NpXkyPF8DmzlsVRQusZhpBsaNvZdM3MP0s59HgleJiO8x00SSwG2dFz0DOZvjdjkQCEsFcwZRA75mCddYhsqTSp89tyTfbgAuHdLaTraCJ2liYj54W27qg8SO_jMYSKfpT7BB5-7y0uytBK45K82ydBDmLDfcYkykRBjbkxxehXYfbWTuaoStd0CoVRHiBtYOpJxPKdYdQkYHdPMCsg0IVKp4jcQhByZeo7a6wi-K_jQ-1tWMqiwBl4a2sda8o1pos4pBwueQMxKrUyfZDRULt9HspE91CiE6TXEoF5ylC-5PQG_XimUBzRI3ZpF3LM2VwTKdfndRcQCvMeakgn42XNYLhsIHvVq2JqBaIkcedHHVutmP9ZfDdNW8C2KjWOewM-aw5x9GKVaUKqP1YjVFegBV_8Nx-r8ChHXeqd0rcV5oSkiuYMR7037qwi2Bx1XmORqwwevWo',
    'https://gdimg.gmarket.co.kr/3088864081/still/280?ver=1724893131',
    'https://img.allurekorea.com/allure/2024/07/style_6687e1239397f.jpeg',
    'https://mblogthumb-phinf.pstatic.net/MjAyNDAzMDFfMjM0/MDAxNzA5MjIxNjg2Mzc5.AigV5-Fzj-9g4df6QXrB-iM837f7_3wPVoFCIIarBXwg.kHTl5-i3cgCEoOj30cI6h7x7Vveqbm304Ia5czEtQ0kg.JPEG/KakaoTalk_20240229_150546357_10.jpg?type=w800',
    'https://cdn.011st.com/11dims/resize/1000x1000/quality/75/11src/product/4987324949/A1.png?253000000',
    'https://www.newstree.kr/data/ntr/image/2021/12/07/ntr202112070002.680x.9.jpg',
    'https://cdn.discoverynews.kr/news/photo/202104/393446_81361_1054.jpg',
    'https://lh6.googleusercontent.com/proxy/WBVlXNK83XB6noX2J8tBXulQShB3ei25bEwhRtG6p6QhAHP9AJarSr7DEbSKtOULxD0FQyWYB9f6dshVUOp_NQT0_4ktT2MunkekOjQ',
    'https://cdn.imweb.me/upload/S202008179a8a184fd9517/dd0a7e8766072.jpg',
    'https://www.geniepark.co.kr/news/photo/202405/53157_41125_509.jpg',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/html/crop/A000000205169/202411011416/crop0/image.oliveyoung.co.kr/uploads/images/editor/QuickUpload/C14207/image/20231221181121/qc14_20231221181121.jpg?created=202411011416',
    'https://www.theguru.co.kr/data/photos/20240835/art_17249035083604_70217c.jpg',
    'https://gd.image-gmkt.com/%EC%86%A1%EC%A3%BD%ED%99%94%EC%9E%A5%ED%92%88-%EC%9E%90%EC%99%B8%EC%84%A0-%EC%B0%A8%EB%8B%A8%EC%A0%9C-%EC%88%98%EB%B6%84-%EC%98%AC%EB%A6%AC%EB%B8%8C%EC%98%81-%ED%86%A4%EC%97%85-%EC%84%A0-%EC%8D%AC-%ED%81%AC%EB%A6%BC-%EB%A1%9C%EC%85%98-%EB%B8%94%EB%A1%9D-%EC%98%A4%EB%9E%98%EC%A7%80%EC%86%8D-250ML/li/380/653/2275653380.g_350-w-et-pj_g.jpg',
    'https://cdn.e2news.com/news/photo/202304/252612_106107_2525.jpg',
    'https://img.danawa.com/prod_img/500000/817/733/img/27733817_1.jpg?_v=20230823141559&shrink=360:360',
    'https://lh5.googleusercontent.com/proxy/e34mLJ2rMgV4PC-oRpEv8_ZRXbCxOo5TBbjk0WiaOgpn8gyXch8kGOAbeYj_QjXRFRuyimt0zHhG0T1gkqDmlRxrC2udg29I5Q',
    'https://cdn.bosa.co.kr/news/photo/202407/2226685_259431_1231.png',
    'https://www.theguru.co.kr/data/photos/20230205/art_16753990972027_cdc77e.png',
    'https://www.beautynury.com/data/editor/cNaQW7O4nbfBdf2x7TO33G8bPfpPw5v.jpg',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/thumbnails/10/0000/0018/A00000018511805ko.jpg?qt=80',
    'https://cdn.pickdailynews.com/news/photo/202407/1433_2769_719.png',
    'https://cdn.bosa.co.kr/news/photo/202201/2165871_197340_3835.jpg',
    'https://image.oliveyoung.co.kr/uploads/images/goods/10/0000/0016/A00000016505802ko.jpg?qt=80',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/thumbnails/10/0000/0020/A00000020926005ko.png?qt=80',
    'https://blog.kakaocdn.net/dn/weXrK/btsyzb1NWXg/H12a4Ucj0ua0x8K6Z40sH0/img.png',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/thumbnails/550/10/0000/0019/A00000019042121ko.jpg?l=ko',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/thumbnails/400/10/0000/0012/A00000012553929ko.jpg?l=ko&SF=webp',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/thumbnails/10/0000/0020/A00000020826411ko.jpg?qt=80',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/html/crop/A000000208264/202411010930/crop0/gi.esmplus.com/wk2007/00000/product/%EC%98%AC%EB%A6%AC%EB%B8%8C%EC%98%81/20241015/%EC%95%B0%ED%94%8C%ED%8C%A9_%EA%B8%B0%ED%9A%8D/04.jpg?created=202411010936',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/thumbnails/10/0000/0019/A00000019061505ko.jpg?qt=80',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/thumbnails/10/0000/0019/A00000019926118ko.jpg?qt=80',
    'https://image.oliveyoung.co.kr/cfimages/cf-goods/uploads/images/thumbnails/400/10/0000/0016/A00000016325413ko.jpg?l=ko&SF=webp',
    'https://img.hankyung.com/photo/202410/2d058d65af505e45345c2ed917443cff.jpg',
  ];

  // 브랜드 리스트
  final brands = [
    '[설화수]',
    '[헤라]',
    '[이니스프리]',
    '[라네즈]',
    '[에뛰드하우스]',
    '[SK-II]',
    '[시세이도]',
    '[랑콤]',
    '[에스티 로더]',
    '[비오템]',
    '[아모레퍼시픽]',
    '[숨37]',
    '[마몽드]',
    '[미샤]',
    '[더페이스샵]',
    '[닥터자르트]',
    '[AHC]',
    '[메디힐]',
    '[네이처리퍼블릭]',
    '[토니모리]'
  ];

  // 제품명 생성 함수 추가
  String generateProductName(int categoryId, int subCategoryId, String brand) {
    final mainAdjectives = [
      '프리미엄',
      '시그니처',
      '울트라',
      '퍼펙트',
      '인텐시브',
      '어드밴스드',
      '리얼',
      '더마',
      '하이드라',
      '센시티브'
    ];
    final effects = [
      '고보습',
      '진정',
      '탄력',
      '미백',
      '영양',
      '수분충전',
      '광채',
      '안티에이징',
      '컴포팅',
      '리페어'
    ];
    final ingredients = [
      '히알루론산',
      '콜라겐',
      '세라마이드',
      '펩타이드',
      '비타민',
      '판테놀',
      '나이아신아마이드',
      '아데노신',
      '프로폴리스',
      '스쿠알란'
    ];
    final special = [
      '대용량',
      '리미티드 에디션',
      '선물세트',
      '기획세트',
      '듀오세트',
      'NEW',
      '3세대',
      '2024 신상',
      '업그레이드'
    ];
    final benefits = [
      '주름개선',
      '미백케어',
      '피부진정',
      '보습케어',
      '피부탄력',
      '모공케어',
      '각질케어',
      '밸런싱',
      '브라이트닝',
      '수분케어'
    ];

    String getRandomItems(List<String> list, int count) {
      list = List.from(list)..shuffle();
      return list.take(count).join(' ');
    }

    switch (categoryId) {
      case 1: // 스킨케어
        final types = ['토너', '에센스', '세럼', '앰플', '크림', '로션', '미스트', '오일'];
        return '$brand ${getRandomItems(special, 1)} ${getRandomItems(mainAdjectives, 1)} ' +
            '${getRandomItems(ingredients, 2)} 함유 ${getRandomItems(effects, 2)} ' +
            '${getRandomItems(benefits, 2)} ${types[random.nextInt(types.length)]} ' +
            '${random.nextInt(100) + 1}ml';

      case 2: // 마스크팩
        final types = ['시트 마스크', '하이드로겔 마스크', '클레이 마스크', '슬리핑 마스크', '패드', '패치'];
        return '$brand ${getRandomItems(special, 1)} ${getRandomItems(mainAdjectives, 1)} ' +
            '${getRandomItems(ingredients, 2)} 더블 케어 ${getRandomItems(effects, 2)} ' +
            '${types[random.nextInt(types.length)]} ${random.nextInt(5) + 1}매입 ' +
            '${getRandomItems(benefits, 2)}';

      case 3: // 클렌징
        final types = ['폼 클렌저', '클렌징 오일', '클렌징 워터', '클렌징 밤', '클렌징 티슈'];
        return '$brand ${getRandomItems(special, 1)} ${getRandomItems(mainAdjectives, 1)} ' +
            'pH${random.nextInt(3) + 5}.5 약산성 ${getRandomItems(ingredients, 1)} ' +
            '${getRandomItems(effects, 2)} ${types[random.nextInt(types.length)]} ' +
            '${random.nextInt(200) + 100}ml 데일리 딥클렌징';

      case 4: // 선케어
        final types = ['선크림', '선스틱', '선쿠션', '선스프레이', '선젤'];
        return '$brand ${getRandomItems(special, 1)} ${getRandomItems(mainAdjectives, 1)} ' +
            '${getRandomItems(ingredients, 2)} 워터프루프 톤업 ' +
            '${types[random.nextInt(types.length)]} SPF${random.nextInt(20) + 30} PA++++ ' +
            '${getRandomItems(effects, 2)} ${random.nextInt(50) + 30}ml';

      case 5: // 메이크업
        final colors = ['로즈', '코랄', '핑크', '베이지', '브라운', '레드', '누드', '피치'];
        final types = ['립스틱', '파운데이션', '마스카라', '아이라이너', '블러셔'];
        final finishes = ['매트', '글로우', '새틴', '크리미', '벨벳', '래디언트', '시머'];
        return '$brand ${getRandomItems(special, 1)} ${getRandomItems(mainAdjectives, 1)} ' +
            '${finishes[random.nextInt(finishes.length)]} ${colors[random.nextInt(colors.length)]} ' +
            '${getRandomItems(ingredients, 1)} ${types[random.nextInt(types.length)]} ' +
            '#${random.nextInt(20) + 1} ${getRandomItems(effects, 2)}';

      case 6: // 뷰티소품
        final types = ['메이크업 퍼프', '화장솜', '브러시', '마스카라 브러시', '파운데이션 브러시'];
        return '$brand ${getRandomItems(special, 1)} ${getRandomItems(mainAdjectives, 1)} ' +
            '${types[random.nextInt(types.length)]} ${random.nextInt(3) + 1}개입 ' +
            '프리미엄 퀄리티 ${getRandomItems(effects, 1)}';

      case 7: // 맨즈케어
        final types = ['올인원', '스킨', '로션', '에센스', '크림'];
        return '$brand 맨즈 ${getRandomItems(mainAdjectives, 1)} ' +
            '${getRandomItems(ingredients, 2)} ${getRandomItems(effects, 2)} ' +
            '${types[random.nextInt(types.length)]} ${random.nextInt(200) + 100}ml ' +
            '${getRandomItems(benefits, 1)}';

      case 8: // 헤어케어
        final types = ['샴푸', '트리트먼트', '에센스', '오일', '미스트'];
        return '$brand ${getRandomItems(special, 1)} ${getRandomItems(mainAdjectives, 1)} ' +
            '${getRandomItems(ingredients, 2)} ${getRandomItems(effects, 2)} ' +
            '${types[random.nextInt(types.length)]} ${random.nextInt(300) + 200}ml ' +
            '${getRandomItems(benefits, 1)}';

      case 9: // 바디케어
        final types = ['바디워시', '바디로션', '바디크림', '바디오일', '바디미스트'];
        return '$brand ${getRandomItems(special, 1)} ${getRandomItems(mainAdjectives, 1)} ' +
            '${getRandomItems(ingredients, 2)} ${getRandomItems(effects, 2)} ' +
            '${types[random.nextInt(types.length)]} ${random.nextInt(400) + 200}ml ' +
            '${getRandomItems(benefits, 1)}';

      default:
        return '$brand 기본 제품';
    }
  }

  final List<ProductModel> products = [];

  // 제품 생성 로직
  // 제품 생성 로직
  for (int categoryId = 1; categoryId <= 9; categoryId++) {
    for (int subCategoryId = 1; subCategoryId <= 5; subCategoryId++) {
      for (int productNum = 1; productNum <= 5; productNum++) {
        int randomIndex = random.nextInt(imageUrls.length);
        String brand = brands[random.nextInt(brands.length)];
        int basePrice = 10000 + (random.nextInt(29) * 10000);

        // rating을 소수점 한 자리로 제한
        double rating =
            3.0 + (random.nextInt(20) / 10); // 3.0부터 4.9까지 0.1 단위로 생성

        products.add(ProductModel(
          productId: '${categoryId}_${subCategoryId}_$productNum',
          name: generateProductName(categoryId, subCategoryId, brand),
          brandName: brand,
          productImageList: [imageUrls[randomIndex],imageUrls[randomIndex],imageUrls[randomIndex]],
          descriptionImageList: [imageUrls[randomIndex],imageUrls[randomIndex],imageUrls[randomIndex]],
          price: basePrice.toString(),
          discountPercent: (random.nextInt(10) + 1) * 5, // 5%부터 50%까지 5단위로 생성
          categoryId: categoryId.toString(),
          subcategoryId: '${categoryId}_$subCategoryId',
          favoriteList: [],
          reviewList: List.generate(random.nextInt(50),
              (index) => 'REVIEW${index.toString().padLeft(3, '0')}'),
          tagList: [
            'NEW',
            if (random.nextBool()) 'BEST',
            if (random.nextBool()) 'SALE'
          ],
          cartList: [],
          visitCount: 100 + random.nextInt(900),
          rating: rating,
          registrationDate:
              DateTime.now().subtract(Duration(days: random.nextInt(365))),
          salesVolume: 50 + random.nextInt(950),
          isBest: random.nextBool(),
          isPopular: random.nextBool(),
        ));
      }
    }
  }

  // BEST 상품 설정
  products.sort((a, b) => b.rating.compareTo(a.rating));
  final bestProductCount = (products.length * 0.2).round();
  for (var i = 0; i < bestProductCount; i++) {
    products[i] = products[i].copyWith(isBest: true);
  }

  // 인기 상품 설정
  products.sort((a, b) => b.reviewList.length.compareTo(a.reviewList.length));
  final popularProductCount = (products.length * 0.3).round();
  for (var i = 0; i < popularProductCount; i++) {
    products[i] = products[i].copyWith(isPopular: true);
  }

  return products;
}
