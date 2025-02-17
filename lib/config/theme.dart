import 'package:flutter/material.dart';
import 'package:onlyveyou/config/color.dart';

ThemeData darkThemeData() {
  return ThemeData(
    primaryColor: Colors.white,
    primarySwatch: Colors.grey,
    hintColor: Colors.tealAccent,
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: AppsColor.darkGray, // 배경색 설정
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.grey[800],
      textTheme: ButtonTextTheme.normal,
    ),
    colorScheme: const ColorScheme.dark(
      // 다크 모드 색상 설정
      primary: Colors.white,
      surface: AppsColor.darkGray, // 배경색 (scaffoldBackgroundColor와 일치)
    ),

    brightness: Brightness.dark, // 다크 모드 명시

    // BottomNavigationBar 테마 설정
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppsColor.darkGray, // 배경색 다크하게

      unselectedItemColor: Colors.grey, // 미선택 아이템 색상
    ),
  );
}

ThemeData lightThemeData() {
  return ThemeData(
    primaryColor: AppsColor.darkGray,
    primarySwatch: Colors.blue,
    hintColor: Colors.orange,
    fontFamily: 'Pretendard',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
      displayLarge: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.red,
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: const ColorScheme.light(
        // 다크 모드 색상 설정
        primary: Colors.black),
    brightness: Brightness.light, // 라이트 모드 명시
  );
}


Color getBackgroundSelectedColor(BuildContext context, bool isSelected) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (isDark) {
    return isSelected ? const Color(0xFF2C2C2C) : const Color(0xFF1C1C1C);
  }
  return isSelected ? Colors.white : Colors.grey[100]!;
}

Color getDarkModeSelectedTextColor(BuildContext context, bool isSelected) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (isDark) {
    return isSelected ? AppsColor.pastelGreen : Colors.white70;
  }
  return isSelected ? AppsColor.pastelGreen : Colors.black87;
}

Color getDarkModeTextColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (isDark) {
    return Colors.white70;
  }
  return Colors.black87;
}

Color getBackgroundColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (isDark) {
    return const Color(0xFF1C1C1C);
  }
  return Colors.white;
}

