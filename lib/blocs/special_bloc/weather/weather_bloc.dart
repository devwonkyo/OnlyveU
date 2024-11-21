//////////////
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/weather_model.dart';
import 'package:onlyveyou/repositories/special/weather/weather_repository.dart';

// Events
abstract class WeatherEvent {}

class FetchWeather extends WeatherEvent {
  final double latitude;
  final double longitude;

  FetchWeather(this.latitude, this.longitude);
}

// States
abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherModel weather;
  WeatherLoaded(this.weather);
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}

// Bloc
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository repository;

  WeatherBloc({required this.repository}) : super(WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
  }

  Future<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    try {
      final weather = await repository.getWeatherData(
        event.latitude,
        event.longitude,
      );
      emit(WeatherLoaded(weather));
    } on WeatherException catch (e) {
      emit(WeatherError(e.toString()));
    } catch (e) {
      emit(WeatherError('날씨 정보를 가져오는데 실패했습니다.'));
    }
  }
}
