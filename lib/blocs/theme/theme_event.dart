// theme_event.dart
import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class SetLightTheme extends ThemeEvent {}

class SetDarkTheme extends ThemeEvent {}

class SetSystemTheme extends ThemeEvent {}
