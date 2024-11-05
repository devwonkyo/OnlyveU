import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final OnlyYouSharedPreference _prefs = OnlyYouSharedPreference();

  ThemeBloc() : super(const ThemeSystem()) {
    on<SetLightTheme>((event, emit) async {
      await _prefs.setThemeMode(false); // Light Mode 저장
      emit(const ThemeLight());
    });

    on<SetDarkTheme>((event, emit) async {
      await _prefs.setThemeMode(true); // Dark Mode 저장
      emit(const ThemeDark());
    });

    on<SetSystemTheme>((event, emit) async {
      await _prefs.setThemeMode(false); // 시스템 모드 설정
      emit(const ThemeSystem());
    });

    on<LoadTheme>((event, emit) async {
      final isDarkMode = await _prefs.getThemeMode(); // 저장된 모드 가져오기
      emit(isDarkMode ? const ThemeDark() : const ThemeLight());
    });
  }
}
