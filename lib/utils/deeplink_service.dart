import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _dynamicLinks = FirebaseDynamicLinks.instance;
  bool _initialized = false;

  // 딥링크 초기화 및 리스너 설정
  Future<void> initialize(GoRouter router) async {
    if (_initialized) return;
    _initialized = true;
    print('dynamiclink initialize');

    // 1. 앱이 종료된 상태에서 딥링크로 열린 경우
    final PendingDynamicLinkData? initialLink =
    await _dynamicLinks.getInitialLink();
    if (initialLink != null) {
      print('딥링크로 열림');
      _handleDynamicLink(initialLink, router);
    }

    // 2. 앱이 실행 중일 때 딥링크를 받는 경우
    _dynamicLinks.onLink.listen((dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData, router);
    }).onError((error) {
      print('Dynamic Link Error: $error');
    });
  }

  // 딥링크 처리
  void _handleDynamicLink(PendingDynamicLinkData data, GoRouter router) {
    final Uri deepLink = data.link;
    final path = deepLink.path;
    final params = deepLink.queryParameters;

    print('Received deep link: $deepLink');
    print('Path: $path');
    print('Parameters: $params');

    // 경로에 따른 처리
    if (path.startsWith('/product-detail')) {
      // URL 형식: .../product-detail?productId=123
      final productId = params['productId'];
      if (productId != null) {
        router.go('/product-detail', extra: productId);
      }
    }
  }

  // 동적 링크 생성
  Future<Uri> createProductShareLink({
    required String productId,
    String? imageUrl,
  }) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://onlyveyou.page.link',
      // 수정: 도메인을 page.link로 변경
      link: Uri.parse('https://onlyveyou.page.link/product-detail?productId=$productId'),
      // 웹으로 강제 이동하도록 설정
      navigationInfoParameters: const NavigationInfoParameters(
        forcedRedirectEnabled: true,  // 웹으로 강제 리다이렉션
      ),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.onlyveyou',
        minimumVersion: 1,
      ),
      // 소셜 메타데이터
      socialMetaTagParameters: imageUrl != null ? SocialMetaTagParameters(
        title: '상품 정보',
        description: '상품 상세 정보를 확인하세요',
        imageUrl: Uri.parse(imageUrl),
      ) : null,
    );

    try {
      final dynamicUrl = await _dynamicLinks.buildLink(parameters);
      print('Generated Dynamic Link: $dynamicUrl'); // 생성된 링크 로깅
      return dynamicUrl;
    } catch (e) {
      print('Error creating dynamic link: $e');
      rethrow;
    }
  }
}