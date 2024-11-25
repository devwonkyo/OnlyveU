import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/special_bloc/weather/location_bloc.dart';
import 'package:onlyveyou/blocs/special_bloc/weather/weather_bloc.dart';
import 'package:onlyveyou/models/weather_model.dart';

/// 날씨 정보를 표시하는 위젯
class WeatherWidget extends StatefulWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  late LocationBloc _locationBloc; // LocationBloc 객체를 저장할 변수 선언

  @override
  void initState() {
    super.initState();
    _locationBloc = context.read<LocationBloc>(); // LocationBloc 초기화
    print('WeatherWidget initState called'); // initState 호출 시 로그 출력
    _initializeLocation(); // 위치 초기화 함수 호출
  }

  /// 위치 초기화 및 Bloc 이벤트 호출
  void _initializeLocation() {
    print('Initializing location...'); // 위치 초기화 로그 출력
    Future.microtask(() {
      final locationBloc = context.read<LocationBloc>();
      print('Requesting location updates...'); // 위치 업데이트 요청 로그 출력
      locationBloc.add(GetCurrentLocation()); // 현재 위치 요청
      locationBloc.add(StartLocationUpdates()); // 위치 업데이트 시작
    });
  }

  @override
  Widget build(BuildContext context) {
    print('WeatherWidget build called'); // 빌드 호출 시 로그 출력

    return MultiBlocListener(
      listeners: [
        // LocationBloc의 상태 변화를 처리
        BlocListener<LocationBloc, LocationState>(
          listener: (context, state) {
            print('LocationBloc state: $state'); // 상태 변화 로그 출력
            if (state is LocationSuccess) {
              // 위치 성공 상태일 때
              print(
                  'Location Success - Lat: ${state.position.latitude}, Lon: ${state.position.longitude}'); // 성공 로그 출력
              context.read<WeatherBloc>().add(
                    FetchWeather(
                      state.position.latitude,
                      state.position.longitude,
                    ), // 날씨 요청 이벤트 전달
                  );
            } else if (state is LocationError) {
              print('Location Error: ${state.message}'); // 에러 로그 출력
            } else if (state is LocationLoading) {
              print('Location Loading...'); // 로딩 상태 로그 출력
            }
          },
        ),
        // WeatherBloc의 상태 변화를 처리
        BlocListener<WeatherBloc, WeatherState>(
          listener: (context, state) {
            print('WeatherBloc state: $state'); // 상태 변화 로그 출력
            if (state is WeatherError) {
              print('Weather Error: ${state.message}'); // 에러 로그 출력
            } else if (state is WeatherLoaded) {
              print(
                  'Weather Loaded: ${state.weather.temperature}°C, ${state.weather.weatherStatus}'); // 성공 로그 출력
            }
          },
        ),
      ],
      child: BlocBuilder<WeatherBloc, WeatherState>(
        // WeatherBloc 상태에 따른 UI 빌드
        builder: (context, state) {
          print('Building WeatherWidget with state: $state'); // 빌드 상태 로그 출력
          if (state is WeatherLoading) {
            return _buildLoadingState(); // 로딩 상태 UI 반환
          } else if (state is WeatherError) {
            return _buildErrorState(state.message); // 에러 상태 UI 반환
          } else if (state is WeatherLoaded) {
            return _buildWeatherInfo(state.weather); // 날씨 정보 UI 반환
          }
          return _buildInitialState(); // 초기 상태 UI 반환
        },
      ),
    );
  }

  @override
  void dispose() {
    _locationBloc.add(StopLocationUpdates()); // 위치 업데이트 종료 이벤트 호출
    super.dispose(); // dispose 호출
  }

  /// 로딩 상태 UI
  Widget _buildLoadingState() {
    return Container(
      height: 200.h, // 컨테이너 높이 설정
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // 배경 그라데이션 설정
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF4E3),
            Color(0xFFFFE4D6),
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          // 로딩 인디케이터 표시
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA41B)),
        ),
      ),
    );
  }

  /// 에러 상태 UI
  Widget _buildErrorState(String message) {
    return Container(
      height: 200.h, // 컨테이너 높이 설정
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // 배경 그라데이션 설정
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF4E3),
            Color(0xFFFFE4D6),
          ],
        ),
      ),
      child: Center(
        child: Column(
          // 중앙 정렬된 컬럼
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40.sp), // 에러 아이콘
            SizedBox(height: 8.h), // 간격
            Text(
              message, // 에러 메시지 텍스트
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  /// 초기 상태 UI
  Widget _buildInitialState() {
    return Container(
      height: 200.h, // 컨테이너 높이 설정
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // 배경 그라데이션 설정
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF4E3),
            Color(0xFFFFE4D6),
          ],
        ),
      ),
      child: Center(
        child: Text(
          '위치를 가져오는 중...', // 초기 상태 메시지
          style: TextStyle(
            fontSize: 16.sp,
            color: Color(0xFF2D3436),
          ),
        ),
      ),
    );
  }

  /// 날씨 정보 표시 UI
  Widget _buildWeatherInfo(WeatherModel weather) {
    return Container(
      height: 200.h, // 컨테이너 높이 설정
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // 배경 그라데이션 설정
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF4E3),
            Color(0xFFFFE4D6),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w), // 패딩 설정
        child: Row(
          children: [
            // 주요 날씨 정보 섹션
            Expanded(
              flex: 5, // 플렉스 설정
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                children: [
                  Icon(
                    _getWeatherIcon(weather.weatherStatus), // 날씨 상태 아이콘
                    size: 60.sp,
                    color: Color(0xFFFFA41B),
                  ),
                  SizedBox(height: 12.h), // 간격
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.round()}°', // 온도 표시
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Container(
                          width: 70.w, // 텍스트 컨테이너 폭 설정
                          child: Text(
                            weather.weatherStatus // 날씨 상태 텍스트
                                .replaceAllMapped(RegExp(r'.{4}'),
                                    (match) => '${match.group(0)}\n') // 줄바꿈 추가
                                .trimRight(), // 마지막 줄바꿈 제거
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFF2D3436),
                              height: 1.2,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 추가 날씨 정보 섹션
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.only(left: 18.w), // 왼쪽 패딩 설정
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                  children: [
                    _buildWeatherDetailRow(
                      icon: Icons.thermostat_outlined, // 아이콘 설정
                      title: '체감온도', // 제목
                      value: '${weather.feelsLike.round()}°', // 값
                      color: Color(0xFFF39C12),
                    ),
                    SizedBox(height: 12.h), // 간격
                    _buildWeatherDetailRow(
                      icon: Icons.air,
                      title: '바람',
                      value: '${weather.windSpeed}m/s',
                      color: Color(0xFF3498DB),
                    ),
                    SizedBox(height: 12.h), // 간격
                    _buildWeatherDetailRow(
                      icon: Icons.water_drop_outlined,
                      title: '습도',
                      value: '${weather.humidity}%',
                      color: Color(0xFF4ECDC4),
                    ),
                    SizedBox(height: 12.h), // 간격
                    _buildWeatherDetailRow(
                      icon: Icons.cloud_outlined,
                      title: '구름량',
                      value: '${weather.cloudiness}%',
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

  /// 날씨 상세 정보 항목 생성
  Widget _buildWeatherDetailRow({
    required IconData icon, // 아이콘 데이터
    required String title, // 항목 제목
    required String value, // 항목 값
    required Color color, // 색상
  }) {
    return Row(
      children: [
        Spacer(), // 공간 확보
        Container(
          width: 90.w, // 컨테이너 폭 설정
          child: Row(
            children: [
              Icon(icon, size: 16.sp, color: color), // 아이콘
              SizedBox(width: 8.w), // 간격
              Text(
                title, // 제목 텍스트
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w), // 간격
        Container(
          width: 60.w, // 값 컨테이너 폭 설정
          child: Text(
            value, // 값 텍스트
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

  /// 날씨 상태에 따른 아이콘 반환
  IconData _getWeatherIcon(String status) {
    if (status.contains('맑음')) {
      return Icons.wb_sunny; // 맑음 상태 아이콘
    } else if (status.contains('구름')) {
      return Icons.cloud; // 구름 상태 아이콘
    } else if (status.contains('비')) {
      return Icons.umbrella; // 비 상태 아이콘
    }
    return Icons.wb_sunny_outlined; // 기본 아이콘
  }
}
