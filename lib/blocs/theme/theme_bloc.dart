// theme_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeSystem()) {
    on<SetLightTheme>((event, emit) {
      emit(const ThemeLight());
    });

    on<SetDarkTheme>((event, emit) {
      emit(const ThemeDark());
    });

    on<SetSystemTheme>((event, emit) {
      emit(const ThemeSystem());
    });
  }
}
