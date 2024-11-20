import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildWeatherHeader();
  }

  Widget _buildWeatherHeader() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF4E3),
            Color(0xFFFFE4D6),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            // 왼쪽 현재 날씨 섹션
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.wb_sunny,
                    size: 60.sp,
                    color: Color(0xFFFFA41B),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '24°',
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          '맑음',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 오른쪽 상세 날씨 정보 섹션
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildWeatherDetailRow(
                      icon: Icons.thermostat_outlined,
                      title: '체감온도',
                      value: '26°',
                      color: Color(0xFFF39C12),
                    ),
                    SizedBox(height: 12.h),
                    _buildWeatherDetailRow(
                      icon: Icons.air,
                      title: '바람',
                      value: '3m/s',
                      color: Color(0xFF3498DB),
                    ),
                    SizedBox(height: 12.h),
                    _buildWeatherDetailRow(
                      icon: Icons.water_drop_outlined,
                      title: '강수확률',
                      value: '10%',
                      color: Color(0xFF4ECDC4),
                    ),
                    SizedBox(height: 12.h),
                    _buildWeatherDetailRow(
                      icon: Icons.cloud_outlined,
                      title: '구름량',
                      value: '20%',
                      color: Color(0xFF95A5A6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        // 왼쪽 여백을 위한 Spacer
        Spacer(),
        // 아이콘과 텍스트를 담는 고정 너비 컨테이너
        Container(
          width: 85.w, // 모든 행의 아이콘과 텍스트가 동일한 위치에서 시작하도록 고정 너비 설정
          child: Row(
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: color,
              ),
              SizedBox(width: 4.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 1.w),
        // 값을 표시하는 고정 너비 텍스트
        Container(
          width: 35.w, // 값의 너비를 고정
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class WeatherStatsSection extends StatelessWidget {
  const WeatherStatsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildWeatherStats();
  }

  Widget _buildWeatherStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildWeatherStat(
            icon: Icons.water_drop,
            label: '습도',
            value: '68%',
            color: Color(0xFF4ECDC4),
          ),
          SizedBox(width: 8.w),
          _buildWeatherStat(
            icon: Icons.wb_sunny_outlined,
            label: '자외선',
            value: '높음',
            color: Color(0xFFFF7E5F),
          ),
          SizedBox(width: 8.w),
          _buildWeatherStat(
            icon: Icons.visibility,
            label: '미세먼지',
            value: '좋음',
            color: Color(0xFF45B649),
          ),
        ],
      ),
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
}
