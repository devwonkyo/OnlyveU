import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onlyveyou/models/weather_model.dart';

class WeatherRepository {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = '7bfbceaf4e40e2a8f8fc982b8511e601';

  final Map<String, WeatherModel> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(minutes: 15);

  String _getCacheKey(double lat, double lon) =>
      '${lat.toStringAsFixed(4)},${lon.toStringAsFixed(4)}';

  bool _isCacheValid(String cacheKey) {
    if (!_cache.containsKey(cacheKey) ||
        !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }
    final age = DateTime.now().difference(_cacheTimestamps[cacheKey]!);
    return age < _cacheDuration;
  }

  Future<WeatherModel> getWeatherData(double lat, double lon) async {
    final cacheKey = _getCacheKey(lat, lon);

    // 캐시된 데이터가 있고 유효한 경우
    if (_isCacheValid(cacheKey)) {
      print('Returning cached weather data');
      return _cache[cacheKey]!;
    }

    try {
      print("Fetching weather data for lat: $lat, lon: $lon");
      final weatherData = await _fetchWeatherData(lat, lon);
      final uvData = await _fetchUVData(lat, lon);
      final airData = await _fetchAirQualityData(lat, lon);

      final combinedData = _combineWeatherData(weatherData, uvData, airData);
      final weatherModel = WeatherModel.fromJson(combinedData);

      // 캐시 업데이트
      _cache[cacheKey] = weatherModel;
      _cacheTimestamps[cacheKey] = DateTime.now();

      print("Weather data received: $weatherData");
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

  String _getErrorMessage(String error) {
    if (error.contains('Invalid API key')) {
      return 'API 키가 유효하지 않습니다.';
    } else if (error.contains('timeout')) {
      return '서버 응답이 너무 늦습니다. 다시 시도해주세요.';
    }
    return '날씨 정보를 가져오는데 실패했습니다.';
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}
