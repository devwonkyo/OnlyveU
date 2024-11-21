import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/models/weather_model.dart';

class WeatherRepository {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = '7bfbceaf4e40e2a8f8fc982b8511e601';

  final FirebaseFirestore _firestore;
  final Map<String, WeatherModel> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(minutes: 15);

  WeatherRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

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

  // 날씨 관련 메서드들...
  Future<WeatherModel> getWeatherData(double lat, double lon) async {
    final cacheKey = _getCacheKey(lat, lon);

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

      _cache[cacheKey] = weatherModel;
      _cacheTimestamps[cacheKey] = DateTime.now();

      print("Weather data received: $weatherData");
      return weatherModel;
    } catch (e) {
      throw WeatherException(_getErrorMessage(e.toString()));
    }
  }

  // 날씨 기반 상품 추천 메서드 추가
  List<String> _getSubcategoriesByWeatherCondition({
    required double uvIndex,
    required int airQuality,
    required int humidity,
  }) {
    List<String> subcategories = [];

    // 자외선 높음 (6.0 이상)
    if (uvIndex >= 6.0) {
      if (airQuality >= 4 && humidity >= 70) {
        // 자외선 높음 + 미세먼지 나쁨 + 습도 높음
        subcategories.addAll(['4_1', '4_2', '3_1', '3_2', '5_4', '1_3']);
      } else if (airQuality >= 4 && humidity <= 30) {
        // 자외선 높음 + 미세먼지 나쁨 + 건조
        subcategories.addAll(['4_1', '4_2', '3_1', '3_2', '1_1', '9_1']);
      } else if (airQuality >= 4) {
        // 자외선 높음 + 미세먼지 나쁨
        subcategories.addAll(['4_1', '4_2', '4_3', '3_1', '3_2', '2_1']);
      } else if (humidity >= 70) {
        // 자외선 높음 + 습도 높음
        subcategories.addAll(['4_1', '4_2', '4_3', '5_4', '8_5', '1_3']);
      } else if (humidity <= 30) {
        // 자외선 높음 + 건조
        subcategories.addAll(['4_1', '4_2', '4_3', '1_1', '9_1', '5_3']);
      } else {
        // 자외선만 높음
        subcategories.addAll(['4_1', '4_2', '4_3', '4_4', '5_2', '8_3']);
      }
    } else if (airQuality >= 4) {
      if (humidity >= 70) {
        subcategories.addAll(['3_1', '3_2', '8_1', '5_4', '1_3', '9_5']);
      } else if (humidity <= 30) {
        subcategories.addAll(['3_1', '3_2', '2_1', '1_1', '9_1', '5_3']);
      } else {
        subcategories.addAll(['3_1', '3_2', '2_1', '8_1', '8_3', '1_2']);
      }
    } else if (humidity >= 70) {
      subcategories.addAll(['1_3', '5_4', '6_1', '8_5', '9_2', '9_5']);
    } else if (humidity <= 30) {
      subcategories.addAll(['1_1', '2_3', '5_3', '8_2', '9_1', '9_3']);
    } else {
      subcategories.addAll(['1_1', '2_1', '3_1', '4_1', '5_1']);
    }

    return subcategories;
  }

  Future<List<ProductModel>> getWeatherBasedProducts(
      WeatherModel weather) async {
    try {
      final subcategories = _getSubcategoriesByWeatherCondition(
        uvIndex: weather.uvIndex,
        airQuality: weather.airQuality,
        humidity: weather.humidity,
      );

      List<ProductModel> recommendedProducts = [];

      for (String subcategoryId in subcategories) {
        // 가장 단순한 쿼리로 변경
        final querySnapshot = await _firestore
            .collection('products')
            .where('subcategoryId', isEqualTo: subcategoryId)
            .get(); // 정렬 조건 제거

        if (querySnapshot.docs.isNotEmpty) {
          // 클라이언트 측에서 정렬
          final docs = querySnapshot.docs.toList()
            ..sort((a, b) {
              final aReviews =
                  List<String>.from(a.data()['reviewList'] ?? []).length;
              final bReviews =
                  List<String>.from(b.data()['reviewList'] ?? []).length;
              return bReviews.compareTo(aReviews); // 리뷰 수 내림차순
            });

          if (docs.isNotEmpty) {
            recommendedProducts.add(
              ProductModel.fromMap(docs.first.data()),
            );
          }
        }
      }

      return recommendedProducts;
    } catch (e) {
      print('Error fetching weather-based products: $e');
      return [];
    }
  }

  // 기존 날씨 관련 헬퍼 메서드들...
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
