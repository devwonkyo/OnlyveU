import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoShareService {
  static final KakaoShareService _instance = KakaoShareService._internal();

  factory KakaoShareService() {
    return _instance;
  }

  KakaoShareService._internal();

  Future<void> shareToKakao({
    required String title,
    required String description,
    required Uri link,
    String? imageUrl,
    String buttonTitle = '공유 받기',
    String productId = '',
  }) async {
    try {
      final kakaoAvail = await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (!kakaoAvail) {
        print("카카오톡 미설치");
        return;
      }

      final FeedTemplate defaultFeed = FeedTemplate(
        content: Content(
          title: title,
          description: description,
          imageUrl: imageUrl != null ? Uri.parse(imageUrl) : null,
          link: Link(
            // webUrl과 mobileWebUrl만 설정하여 웹으로만 이동하도록 함
            webUrl: link,
            mobileWebUrl: link,
            androidExecutionParams: {
              'productId': productId,
              'screen': '/product-detail',
              // 필요한 다른 파라미터들 추가
            },
          ),
        ),
        buttons: [
          Button(
            title: buttonTitle,
            link: Link(
              webUrl: link,
              mobileWebUrl: link,
              androidExecutionParams: {
                'productId': productId,
                'screen': '/product-detail',
                // 필요한 다른 파라미터들 추가
              },
            ),
          ),
        ],
        buttonTitle: buttonTitle,
      );

      Uri uri = await ShareClient.instance.shareDefault(template: defaultFeed);
      await ShareClient.instance.launchKakaoTalk(uri);

    } catch (e) {
      print('카카오톡 공유 실패: $e');
      rethrow;
    }
  }
}