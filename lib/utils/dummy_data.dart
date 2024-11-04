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
    '[비오템]'
  ];

  final skinCareProducts = [
    '고농축 수분 크림 100ml 대용량',
    '리커버리 에센스 스페셜 에디션 120ml',
    '딥 클렌징 포뮬라 토너 200ml',
    '비타민 C 앰플 세트 30ml x 3',
    '프리미엄 로션 지복합성용 150ml',
    '순한 클렌징 폼 포민트 케어 180ml',
    '피부탄력 세럼 집중관리형 50ml',
    '수분 충전 마스크팩 10개입',
  ];
  final makeupProducts = [
    '풀 커버 파운데이션 SPF50+ PA+++ 30ml',
    '롱래스팅 립스틱 세트 - 매트&글로스 2종',
    '볼륨 마스카라 24시간 지속력 워터프루프',
    '아이섀도우 팔레트 & 아이라이너 세트',
    '울트라 커버 컨실러 듀오 세트 15g',
    '내추럴 글로우 블러셔 & 하이라이터',
    '올데이 세팅 아이브로우 펜슬 - 내추럴 브라운',
  ];
  final sunCareProducts = [
    '고보습 선크림 SPF50+ PA+++ 100ml',
    '멀티 프로텍션 선스틱 내추럴 핏',
    '쿨링 선스프레이 150ml 대용량',
    '프리미엄 선쿠션 SPF50+ PA+++',
  ];

  final List<ProductModel> products = [];
  final usedIndices = <int>{}; // 사용된 이미지 인덱스를 추적하기 위한 Set

  for (int i = 0; i < 50; i++) {
    // 아직 사용되지 않은 랜덤 인덱스 선택
    int randomIndex;
    do {
      randomIndex = random.nextInt(imageUrls.length);
    } while (usedIndices.contains(randomIndex) &&
        usedIndices.length < imageUrls.length);

    usedIndices.add(randomIndex);
    final selectedImage = imageUrls[randomIndex];
    final productImages = [selectedImage];

    final brand = brands[random.nextInt(brands.length)];
    List<String> productTypes;
    String categoryId;

    if (i < 25) {
      productTypes = skinCareProducts;
      categoryId = '1';
    } else if (i < 40) {
      productTypes = makeupProducts;
      categoryId = '2';
    } else {
      productTypes = sunCareProducts;
      categoryId = '3';
    }

    final productType = productTypes[random.nextInt(productTypes.length)];
    final basePrice = 10000 + (random.nextInt(29) * 10000);

    products.add(ProductModel(
      productId: 'PROD${i.toString().padLeft(3, '0')}',
      name: '${brand} ${productType}',
      brandName: brand,
      productImageList: productImages,
      descriptionImageList: productImages,
      price: basePrice.toString(),
      discountPercent: (random.nextInt(4) + 1) * 10,
      categoryId: categoryId,
      subcategoryId: '${categoryId}_${random.nextInt(3) + 1}',
      favoriteList: [],
      reviewList: List.generate(random.nextInt(50),
          (index) => 'REVIEW${index.toString().padLeft(3, '0')}'),
      tagList: List.generate(random.nextInt(3) + 1,
          (index) => 'TAG${(index + 1).toString().padLeft(3, '0')}'),
      cartList: [],
      visitCount: 100 + random.nextInt(900),
      rating: 3.0 + (random.nextDouble() * 2.0),
      registrationDate:
          DateTime.now().subtract(Duration(days: random.nextInt(365))),
      salesVolume: 50 + random.nextInt(950),
      isBest: random.nextBool(),
      isPopular: random.nextBool(),
    ));
  }

  return products;
}
