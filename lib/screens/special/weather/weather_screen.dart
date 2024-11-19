// weather_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            child: _buildWeatherHeader(),
          ),
          SliverToBoxAdapter(
            child: _buildLocationSection(),
          ),
          SliverToBoxAdapter(
            child: _buildWeatherStats(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '날씨 맞춤 추천',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16.sp,
                          color: Color(0xFF2D3436),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '필터',
                          style: TextStyle(
                            color: Color(0xFF2D3436),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildRecommendationGrid(),
        ],
      ),
    );
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
                    size: 52.sp,
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

  Widget _buildLocationSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Color(0xFFFF7E5F), size: 24.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 위치',
                  style: TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  '서울특별시 강남구',
                  style: TextStyle(
                    color: Color(0xFF2D3436),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFA41B), Color(0xFFFF7E5F)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF7E5F).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '위치 변경',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildRecommendationGrid() {
    return SliverPadding(
      padding: EdgeInsets.all(16.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 0.6, // 변경: 0.75에서 0.6으로 수정하여 카드 높이 증가
          mainAxisExtent: 280.h, // 추가: 명시적인 높이 설정
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildRecommendationCard(),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 150.h,
              color: Color(0xFFF1F2F6),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 40.sp,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFA41B), Color(0xFFFF7E5F)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF7E5F).withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wb_sunny_outlined,
                            color: Colors.white,
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '날씨 맞춤',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '여름 필수템',
                  style: TextStyle(
                    color: Color(0xFF2D3436),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF4E3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '30%',
                        style: TextStyle(
                          color: Color(0xFFFFA41B),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '₩89,000',
                      style: TextStyle(
                        color: Color(0xFF2D3436),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Color(0xFFFFD700),
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '4.5',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '(128)',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
