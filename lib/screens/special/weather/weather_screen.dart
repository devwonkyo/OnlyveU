import 'package:flutter/material.dart';
import 'package:onlyveyou/screens/special/weather/widgets/location_widget.dart';
import 'package:onlyveyou/screens/special/weather/widgets/weather_product_recommendation_widget.dart';
import 'package:onlyveyou/screens/special/weather/widgets/weather_stats_section.dart';
import 'package:onlyveyou/screens/special/weather/widgets/weather_widget.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '날씨 추천',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF2D3436)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: WeatherWidget(),
          ),
          SliverToBoxAdapter(
            child: LocationWidget(),
          ),
          SliverToBoxAdapter(
            child: WeatherStatsSection(),
          ),
          WeatherProductRecommendationWidget(),
        ],
      ),
    );
  }
}
// 단일 날씨 조건:
// 1. 자외선 높음 (최우선)
// • 4_1, 4_2, 4_3, 4_4, 5_2, 8_3
// 2. 미세먼지 나쁨
// • 3_1, 3_2, 2_1, 8_1, 8_3, 1_2
// 3. 습도 높음
// • 1_3, 5_4, 6_1, 8_5, 9_2, 9_5
// 4. 건조
// • 1_1, 2_3, 5_3, 8_2, 9_1, 9_3
// 복합 날씨 조건:
// 1. 자외선 높음 + 미세먼지 나쁨
// • 4_1, 4_2, 4_3 (자외선 대비)
// • 3_1, 3_2, 2_1 (미세먼지 대비)
// 2. 자외선 높음 + 습도 높음
// • 4_1, 4_2, 4_3 (자외선 대비)
// • 5_4, 8_5, 1_3 (습도 대비)
// 3. 자외선 높음 + 건조
// • 4_1, 4_2, 4_3 (자외선 대비)
// • 1_1, 9_1, 5_3 (보습 대비)
// 4. 미세먼지 나쁨 + 습도 높음
// • 3_1, 3_2, 8_1 (미세먼지 대비)
// • 5_4, 1_3, 9_5 (습도 대비)
// 5. 미세먼지 나쁨 + 건조
// • 3_1, 3_2, 2_1 (미세먼지 대비)
// • 1_1, 9_1, 5_3 (보습 대비)
// 6. 습도 높음 + 건조 (드문 케이스)
// • 1_3, 5_4, 8_5 (습도 대비)
// • 1_1, 9_1, 2_3 (보습 대비)
// 극한 날씨 (3가지 조건 복합):
// 1. 자외선 높음 + 미세먼지 나쁨 + 습도 높음
// • 4_1, 4_2 (자외선 최우선)
// • 3_1, 3_2 (미세먼지 대비)
// • 5_4, 1_3 (습도 대비)
// 2. 자외선 높음 + 미세먼지 나쁨 + 건조
// • 4_1, 4_2 (자외선 최우선)
// • 3_1, 3_2 (미세먼지 대비)
// • 1_1, 9_1 (보습 대비)
