// theme_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeInitial()) {
    on<ToggleTheme>((event, emit) {
      if (state is ThemeLight) {
        emit(const ThemeDark());
      } else if (state is ThemeDark) {
        emit(const ThemeLight());
      } else {
        emit(const ThemeSystem());
      }
    });

    on<SetSystemTheme>((event, emit) {
      emit(const ThemeSystem());
    });
  }
}
