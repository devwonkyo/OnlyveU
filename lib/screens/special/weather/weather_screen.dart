import 'package:flutter/material.dart';
import 'package:onlyveyou/screens/special/weather/widgets/location_widget.dart';
import 'package:onlyveyou/screens/special/weather/widgets/weather_product_recommendation_widget.dart';
import 'package:onlyveyou/screens/special/weather/widgets/weather_stats_section.dart';
import 'package:onlyveyou/screens/special/weather/widgets/weather_widget.dart';

/// 날씨 화면을 표시하는 WeatherScreen 위젯
/// - 날씨 관련 다양한 정보를 하나의 화면에 통합하여 제공
/// - 사용자 위치, 날씨 정보, 추천 제품 등 UI 구성
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA), // 배경색 설정
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 투명한 배경
        elevation: 0, // 앱바 그림자 제거
        title: Text(
          '날씨 추천', // 앱바 제목
          style: TextStyle(
            color: Color(0xFF2D3436), // 텍스트 색상
            fontWeight: FontWeight.bold, // 텍스트 두께
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF2D3436)), // 아이콘 색상 설정
      ),
      body: CustomScrollView(
        // 스크롤 가능한 UI 구성
        slivers: [
          // 날씨 정보를 표시하는 WeatherWidget
          SliverToBoxAdapter(
            child: WeatherWidget(),
          ),
          // 사용자 위치 정보를 표시하는 LocationWidget
          SliverToBoxAdapter(
            child: LocationWidget(),
          ),
          // 날씨 통계 정보를 표시하는 WeatherStatsSection
          SliverToBoxAdapter(
            child: WeatherStatsSection(),
          ),
          // 날씨 기반 제품 추천 정보를 표시하는 WeatherProductRecommendationWidget
          WeatherProductRecommendationWidget(),
        ],
      ),
    );
  }
}

/// 단일 날씨 조건
/// 1. 자외선 높음 (최우선): UV 지수가 높을 때 추천 제품
///    제품 추천 ID: 4_1, 4_2, 4_3, 4_4, 5_2, 8_3
/// 2. 미세먼지 나쁨: PM2.5, PM10 농도가 높은 상태에 대한 제품 추천
///    제품 추천 ID: 3_1, 3_2, 2_1, 8_1, 8_3, 1_2
/// 3. 습도 높음: 높은 습도 상태에서 유용한 제품
///    제품 추천 ID: 1_3, 5_4, 6_1, 8_5, 9_2, 9_5
/// 4. 건조: 습도가 낮은 상태에 대비한 제품 추천
///    제품 추천 ID: 1_1, 2_3, 5_3, 8_2, 9_1, 9_3

/// 복합 날씨 조건
/// 1. 자외선 높음 + 미세먼지 나쁨
///    - 자외선 대비: 4_1, 4_2, 4_3
///    - 미세먼지 대비: 3_1, 3_2, 2_1
/// 2. 자외선 높음 + 습도 높음
///    - 자외선 대비: 4_1, 4_2, 4_3
///    - 습도 대비: 5_4, 8_5, 1_3
/// 3. 자외선 높음 + 건조
///    - 자외선 대비: 4_1, 4_2, 4_3
///    - 보습 대비: 1_1, 9_1, 5_3
/// 4. 미세먼지 나쁨 + 습도 높음
///    - 미세먼지 대비: 3_1, 3_2, 8_1
///    - 습도 대비: 5_4, 1_3, 9_5
/// 5. 미세먼지 나쁨 + 건조
///    - 미세먼지 대비: 3_1, 3_2, 2_1
///    - 보습 대비: 1_1, 9_1, 5_3
/// 6. 습도 높음 + 건조 (드문 케이스)
///    - 습도 대비: 1_3, 5_4, 8_5
///    - 보습 대비: 1_1, 9_1, 2_3

/// 극한 날씨 (3가지 조건 복합)
/// 1. 자외선 높음 + 미세먼지 나쁨 + 습도 높음
///    - 자외선 최우선: 4_1, 4_2
///    - 미세먼지 대비: 3_1, 3_2
///    - 습도 대비: 5_4, 1_3
/// 2. 자외선 높음 + 미세먼지 나쁨 + 건조
///    - 자외선 최우선: 4_1, 4_2
///    - 미세먼지 대비: 3_1, 3_2
///    - 보습 대비: 1_1, 9_1
