import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/special_bloc/weather/weather_bloc.dart';

class WeatherStatsSection extends StatelessWidget {
  const WeatherStatsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoaded) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _buildWeatherStat(
                  icon: Icons.water_drop,
                  label: '습도',
                  value: '${state.weather.humidity}%',
                  color: Color(0xFF4ECDC4),
                ),
                SizedBox(width: 8.w),
                _buildWeatherStat(
                  icon: Icons.wb_sunny_outlined,
                  label: '자외선',
                  value: _getUVIndexText(state.weather.uvIndex),
                  color: Color(0xFFFF7E5F),
                ),
                SizedBox(width: 8.w),
                _buildWeatherStat(
                  icon: Icons.visibility,
                  label: '미세먼지',
                  value: _getAirQualityText(state.weather.airQuality),
                  color: Color(0xFF45B649),
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildWeatherStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 12.sp,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Color(0xFF2D3436),
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUVIndexText(double uvIndex) {
    if (uvIndex >= 11) return '위험';
    if (uvIndex >= 8) return '매우 높음';
    if (uvIndex >= 6) return '높음';
    if (uvIndex >= 3) return '보통';
    return '낮음';
  }

  String _getAirQualityText(int aqi) {
    switch (aqi) {
      case 1:
        return '매우좋음';
      case 2:
        return '좋음';
      case 3:
        return '보통';
      case 4:
        return '나쁨';
      case 5:
        return '매우나쁨';
      default:
        return '정보없음';
    }
  }
}
