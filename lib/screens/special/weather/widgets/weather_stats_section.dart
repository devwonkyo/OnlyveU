import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/special_bloc/weather/weather_bloc.dart';

/// 날씨 통계 섹션을 표시하는 위젯
class WeatherStatsSection extends StatelessWidget {
  const WeatherStatsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // WeatherBloc 상태에 따라 UI 빌드
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoaded) {
          // 날씨 정보가 로드된 상태일 때 통계 표시
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w), // 좌우 여백 설정
            child: Row(
              children: [
                // 습도 통계 표시
                _buildWeatherStat(
                  icon: Icons.water_drop,
                  label: '습도',
                  value: '${state.weather.humidity}%', // 습도 값
                  color: Color(0xFF4ECDC4), // 아이콘 색상
                ),
                SizedBox(width: 8.w), // 요소 간 간격
                // 자외선 지수 통계 표시
                _buildWeatherStat(
                  icon: Icons.wb_sunny_outlined,
                  label: '자외선',
                  value: _getUVIndexText(state.weather.uvIndex), // 자외선 지수 텍스트
                  color: Color(0xFFFF7E5F), // 아이콘 색상
                ),
                SizedBox(width: 8.w),
                // 미세먼지 통계 표시
                _buildWeatherStat(
                  icon: Icons.visibility,
                  label: '미세먼지',
                  value:
                      _getAirQualityText(state.weather.airQuality), // 공기질 텍스트
                  color: Color(0xFF45B649), // 아이콘 색상
                ),
              ],
            ),
          );
        }
        // 로드된 상태가 아니면 빈 위젯 반환
        return SizedBox.shrink();
      },
    );
  }

  /// 단일 날씨 통계를 표시하는 카드 위젯
  Widget _buildWeatherStat({
    required IconData icon, // 아이콘 데이터
    required String label, // 통계 이름
    required String value, // 통계 값
    required Color color, // 아이콘 및 강조 색상
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w), // 카드 내부 여백
        decoration: BoxDecoration(
          color: Colors.white, // 카드 배경색
          borderRadius: BorderRadius.circular(12), // 모서리 둥글게 처리
          boxShadow: [
            // 그림자 효과
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // 그림자 색상
              blurRadius: 10, // 그림자 블러 정도
              offset: Offset(0, 2), // 그림자 위치
            ),
          ],
        ),
        child: Column(
          children: [
            // 통계 아이콘
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 4.h), // 아이콘과 텍스트 간격
            // 통계 이름
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF7F8C8D), // 텍스트 색상
                fontSize: 12.sp, // 텍스트 크기
              ),
            ),
            // 통계 값
            Text(
              value,
              style: TextStyle(
                color: Color(0xFF2D3436), // 텍스트 색상
                fontSize: 14.sp, // 텍스트 크기
                fontWeight: FontWeight.bold, // 텍스트 굵기
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 자외선 지수에 따른 텍스트 반환
  String _getUVIndexText(double uvIndex) {
    if (uvIndex >= 11) return '위험'; // 자외선 지수 11 이상
    if (uvIndex >= 8) return '매우 높음'; // 자외선 지수 8~10
    if (uvIndex >= 6) return '높음'; // 자외선 지수 6~7
    if (uvIndex >= 3) return '보통'; // 자외선 지수 3~5
    return '낮음'; // 자외선 지수 0~2
  }

  /// 공기질 지수에 따른 텍스트 반환
  String _getAirQualityText(int aqi) {
    switch (aqi) {
      case 1:
        return '매우좋음'; // AQI 1
      case 2:
        return '좋음'; // AQI 2
      case 3:
        return '보통'; // AQI 3
      case 4:
        return '나쁨'; // AQI 4
      case 5:
        return '매우나쁨'; // AQI 5
      default:
        return '정보없음'; // 그 외 값
    }
  }
}
