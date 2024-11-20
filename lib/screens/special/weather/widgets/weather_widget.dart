import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/special_bloc/weather/location_bloc.dart';
import 'package:onlyveyou/blocs/special_bloc/weather/weather_bloc.dart';
import 'package:onlyveyou/models/weather_model.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  late LocationBloc _locationBloc;

  @override
  void initState() {
    super.initState();
    _locationBloc = context.read<LocationBloc>();
    print('WeatherWidget initState called');
    _initializeLocation();
  }

  void _initializeLocation() {
    print('Initializing location...');
    Future.microtask(() {
      final locationBloc = context.read<LocationBloc>();
      print('Requesting location updates...');
      locationBloc.add(GetCurrentLocation());
      locationBloc.add(StartLocationUpdates());
    });
  }

  @override
  Widget build(BuildContext context) {
    print('WeatherWidget build called');

    return MultiBlocListener(
      listeners: [
        BlocListener<LocationBloc, LocationState>(
          listener: (context, state) {
            print('LocationBloc state: $state');
            if (state is LocationSuccess) {
              print(
                  'Location Success - Lat: ${state.position.latitude}, Lon: ${state.position.longitude}');
              context.read<WeatherBloc>().add(
                    FetchWeather(
                      state.position.latitude,
                      state.position.longitude,
                    ),
                  );
            } else if (state is LocationError) {
              print('Location Error: ${state.message}');
            } else if (state is LocationLoading) {
              print('Location Loading...');
            }
          },
        ),
        BlocListener<WeatherBloc, WeatherState>(
          listener: (context, state) {
            print('WeatherBloc state: $state');
            if (state is WeatherError) {
              print('Weather Error: ${state.message}');
            } else if (state is WeatherLoaded) {
              print(
                  'Weather Loaded: ${state.weather.temperature}°C, ${state.weather.weatherStatus}');
            }
          },
        ),
      ],
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          print('Building WeatherWidget with state: $state');
          if (state is WeatherLoading) {
            return _buildLoadingState();
          } else if (state is WeatherError) {
            return _buildErrorState(state.message);
          } else if (state is WeatherLoaded) {
            return _buildWeatherInfo(state.weather);
          }
          return _buildInitialState();
        },
      ),
    );
  }

  @override
  void dispose() {
    _locationBloc.add(StopLocationUpdates());
    super.dispose();
  }

  Widget _buildLoadingState() {
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
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA41B)),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
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
      child: Center(
        child: Text(
          '위치를 가져오는 중...',
          style: TextStyle(
            fontSize: 16.sp,
            color: Color(0xFF2D3436),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(WeatherModel weather) {
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
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getWeatherIcon(weather.weatherStatus),
                    size: 60.sp,
                    color: Color(0xFFFFA41B),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.round()}°',
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          weather.weatherStatus,
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
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.only(left: 18.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildWeatherDetailRow(
                      icon: Icons.thermostat_outlined,
                      title: '체감온도',
                      value: '${weather.feelsLike.round()}°',
                      color: Color(0xFFF39C12),
                    ),
                    SizedBox(height: 12.h),
                    _buildWeatherDetailRow(
                      icon: Icons.air,
                      title: '바람',
                      value: '${weather.windSpeed}m/s',
                      color: Color(0xFF3498DB),
                    ),
                    SizedBox(height: 12.h),
                    _buildWeatherDetailRow(
                      icon: Icons.water_drop_outlined,
                      title: '강수확률',
                      value: '${weather.rainProbability.round()}%',
                      color: Color(0xFF4ECDC4),
                    ),
                    SizedBox(height: 12.h),
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

  Widget _buildWeatherDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Spacer(),
        Container(
          width: 90.w,
          child: Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
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
        SizedBox(width: 10.w),
        Container(
          width: 50.w,
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

  IconData _getWeatherIcon(String status) {
    if (status.contains('맑음')) {
      return Icons.wb_sunny;
    } else if (status.contains('구름')) {
      return Icons.cloud;
    } else if (status.contains('비')) {
      return Icons.umbrella;
    }
    return Icons.wb_sunny_outlined;
  }
}
