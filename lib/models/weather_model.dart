class WeatherModel {
  final double temperature; // 현재 온도
  final double feelsLike; // 체감 온도
  final int humidity; // 습도
  final double windSpeed; // 풍속
  final int cloudiness; // 구름량
  final double rainProbability; // 강수확률
  final double uvIndex; // 자외선 지수
  final String weatherStatus; // 날씨 상태 (맑음, 흐림 등)
  final int airQuality; // 대기질 상태

  WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.cloudiness,
    required this.rainProbability,
    required this.uvIndex,
    required this.weatherStatus,
    required this.airQuality,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      cloudiness: json['clouds']['all'] as int,
      rainProbability:
          json['pop'] != null ? (json['pop'] as num).toDouble() * 100 : 0.0,
      uvIndex: json['uvi'] ?? 0.0,
      weatherStatus: (json['weather'] as List).first['description'] as String,
      airQuality: json['air_quality'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'cloudiness': cloudiness,
      'rainProbability': rainProbability,
      'uvIndex': uvIndex,
      'weatherStatus': weatherStatus,
      'airQuality': airQuality,
    };
  }

  // 날씨 상태에 따른 아이콘 정보 반환
  String getWeatherIcon() {
    // 날씨 상태에 따라 적절한 아이콘 반환
    if (weatherStatus.contains('맑음')) {
      return 'assets/icons/sunny.png';
    } else if (weatherStatus.contains('구름')) {
      return 'assets/icons/cloudy.png';
    } else if (weatherStatus.contains('비')) {
      return 'assets/icons/rainy.png';
    }
    return 'assets/icons/default.png';
  }

  // 날씨 기반 추천 카테고리 반환
  List<String> getRecommendedCategories() {
    List<String> categories = [];

    if (temperature > 28) {
      categories.addAll(['여름옷', '자외선차단']);
    } else if (temperature < 10) {
      categories.addAll(['겨울옷', '방한용품']);
    }

    if (rainProbability > 50) {
      categories.add('우산');
    }

    if (uvIndex > 5) {
      categories.addAll(['선크림', '모자']);
    }

    return categories;
  }
}
