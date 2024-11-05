import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class SetLightTheme extends ThemeEvent {}

class SetDarkTheme extends ThemeEvent {}

class SetSystemTheme extends ThemeEvent {}

// 앱 시작 시 테마 모드를 로드하는 이벤트 추가
class LoadTheme extends ThemeEvent {}
