import 'package:flutter/material.dart';

class ScreenUtil {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late Orientation orientation;

  // 디자인 기준 크기 (올리브영 앱 기준)
  static const double designWidth = 375.0; // iPhone 기준
  static const double designHeight = 812.0; // iPhone 기준

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;

    // 디폴트 사이즈는 화면 너비의 1%로 설정
    defaultSize = screenWidth / 100;
  }

  // 디자인 크기 기준으로 너비 값을 반환
  static double getProportionateScreenWidth(double inputWidth) {
    return (inputWidth / designWidth) * screenWidth;
  }

  // 디자인 크기 기준으로 높이 값을 반환
  static double getProportionateScreenHeight(double inputHeight) {
    return (inputHeight / designHeight) * screenHeight;
  }

  // 반응형 폰트 사이즈
  static double getAdaptiveFontSize(double fontSize) {
    double scaleFactor = screenWidth / designWidth;
    return fontSize * scaleFactor;
  }

  // 디바이스 종류 확인
  static bool get isTablet => screenWidth >= 600;
  static bool get isPhone => screenWidth < 600;

  // 안전 영역 패딩 가져오기
  static double get safeAreaTop => _mediaQueryData.padding.top;
  static double get safeAreaBottom => _mediaQueryData.padding.bottom;
}

// 확장 메서드 추가
extension SizeExtension on num {
  double get w => ScreenUtil.getProportionateScreenWidth(toDouble());
  double get h => ScreenUtil.getProportionateScreenHeight(toDouble());
  double get sp => ScreenUtil.getAdaptiveFontSize(toDouble());
}
