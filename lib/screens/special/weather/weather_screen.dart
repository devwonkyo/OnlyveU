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
