import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onlyveyou/models/weather_model.dart';

class WeatherRepository {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = '7bfbceaf4e40e2a8f8fc982b8511e601';

  final Map<String, WeatherModel> _cache = {};
  final Duration _cacheDuration = const Duration(minutes: 30);
  final Map<String, DateTime> _cacheTimestamp = {};

  Future<WeatherModel> getWeatherData(double lat, double lon) async {
    if (_shouldUseCache(lat, lon)) {
      return _getCachedData(lat, lon);
    }
    return _fetchAndCacheWeatherData(lat, lon);
  }

  bool _shouldUseCache(double lat, double lon) {
    final cacheKey = _getCacheKey(lat, lon);
    final now = DateTime.now();
    return _cache.containsKey(cacheKey) &&
        _cacheTimestamp[cacheKey] != null &&
        now.difference(_cacheTimestamp[cacheKey]!) < _cacheDuration;
  }

  WeatherModel _getCachedData(double lat, double lon) {
    return _cache[_getCacheKey(lat, lon)]!;
  }

  Future<WeatherModel> _fetchAndCacheWeatherData(double lat, double lon) async {
    try {
      print("Fetching weather data for lat: $lat, lon: $lon"); // 디버깅 로그
      final weatherData = await _fetchWeatherData(lat, lon);
      print("Weather data received: $weatherData"); // 디버깅 로그
      final uvData = await _fetchUVData(lat, lon);
      final airData = await _fetchAirQualityData(lat, lon);

      final combinedData = _combineWeatherData(weatherData, uvData, airData);
      final weatherModel = WeatherModel.fromJson(combinedData);

      _updateCache(lat, lon, weatherModel);
      return weatherModel;
    } catch (e) {
      throw WeatherException(_getErrorMessage(e.toString()));
    }
  }

  Future<Map<String, dynamic>> _fetchWeatherData(double lat, double lon) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=kr'));

    if (response.statusCode != 200) {
      throw WeatherException('날씨 데이터를 가져오는데 실패했습니다.');
    }

    return json.decode(response.body);
  }

  Future<double> _fetchUVData(double lat, double lon) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/uvi?lat=$lat&lon=$lon&appid=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['value'] ?? 0.0;
      }
      return 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  Future<int> _fetchAirQualityData(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          '$_baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['list'][0]['main']['aqi'] ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Map<String, dynamic> _combineWeatherData(
    Map<String, dynamic> weather,
    double uvIndex,
    int airQuality,
  ) {
    return {
      ...weather,
      'uvi': uvIndex,
      'air_quality': airQuality,
    };
  }

  void _updateCache(double lat, double lon, WeatherModel weather) {
    final cacheKey = _getCacheKey(lat, lon);
    _cache[cacheKey] = weather;
    _cacheTimestamp[cacheKey] = DateTime.now();
  }

  String _getCacheKey(double lat, double lon) => '$lat-$lon';

  String _getErrorMessage(String error) {
    if (error.contains('Invalid API key')) {
      return 'API 키가 유효하지 않습니다.';
    } else if (error.contains('timeout')) {
      return '서버 응답이 너무 늦습니다. 다시 시도해주세요.';
    }
    return '날씨 정보를 가져오는데 실패했습니다.';
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}
