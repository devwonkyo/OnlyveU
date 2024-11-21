import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
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
  final List<ProductModel> recommendedProducts;
  final String recommendationReason;

  WeatherLoaded({
    required this.weather,
    required this.recommendedProducts,
    required this.recommendationReason,
  });
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

  String _getRecommendationReason(WeatherModel weather) {
    if (weather.uvIndex >= 6.0) {
      if (weather.airQuality >= 4 && weather.humidity >= 70) {
        return '자외선이 강하고 미세먼지가 나쁘며 습도가 높아요';
      } else if (weather.airQuality >= 4 && weather.humidity <= 30) {
        return '자외선이 강하고 미세먼지가 나쁘며 건조해요';
      } else if (weather.airQuality >= 4) {
        return '자외선이 강하고 미세먼지가 나빠요';
      } else if (weather.humidity >= 70) {
        return '자외선이 강하고 습도가 높아요';
      } else if (weather.humidity <= 30) {
        return '자외선이 강하고 건조해요';
      }
      return '자외선이 강해요';
    } else if (weather.airQuality >= 4) {
      if (weather.humidity >= 70) {
        return '미세먼지가 나쁘고 습도가 높아요';
      } else if (weather.humidity <= 30) {
        return '미세먼지가 나쁘고 건조해요';
      }
      return '미세먼지가 나빠요';
    } else if (weather.humidity >= 70) {
      return '습도가 높아요';
    } else if (weather.humidity <= 30) {
      return '건조해요';
    }
    return '오늘을 위한 추천 제품이에요';
  }

  Future<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    try {
      // 날씨 데이터 가져오기
      final weather = await repository.getWeatherData(
        event.latitude,
        event.longitude,
      );

      // 날씨 기반 상품 추천 가져오기
      final recommendedProducts =
          await repository.getWeatherBasedProducts(weather);

      // 추천 이유 생성
      final recommendationReason = _getRecommendationReason(weather);

      emit(WeatherLoaded(
        weather: weather,
        recommendedProducts: recommendedProducts,
        recommendationReason: recommendationReason,
      ));
    } on WeatherException catch (e) {
      emit(WeatherError(e.toString()));
    } catch (e) {
      emit(WeatherError('날씨 정보를 가져오는데 실패했습니다.'));
    }
  }
}
