import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/screens/home/todaysale/widgets/todaysale_card_widget.dart';
import 'package:onlyveyou/utils/styles.dart';

class TodaySaleTabScreen extends StatefulWidget {
  const TodaySaleTabScreen({Key? key}) : super(key: key);

  @override
  State<TodaySaleTabScreen> createState() => _TodaySaleTabScreenState();
}

class _TodaySaleTabScreenState extends State<TodaySaleTabScreen> {
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime(); //^ 초기 시간 계산
    _startTimer(); //^ 타이머 시작
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    // 자정에서 9시간을 뺀 시간을 기준으로 설정
    final midnight = DateTime(now.year, now.month, now.day + 1)
        .subtract(Duration(hours: 9)); //^
    _remainingTime = midnight.difference(now); //^ 현재 시간과 자정 간의 차이 계산
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > Duration.zero) {
          _remainingTime -= Duration(seconds: 1); //^ 1초씩 감소
        } else {
          _timer.cancel(); //^ 남은 시간이 0이 되면 타이머 취소
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = (duration.inHours % 24).toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 타이틀과 시간
        Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // 제목을 가운데 정렬
              Center(
                child: Text(
                  '딱 하루만! 오늘의 특가 찬스',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              // Row를 mainAxisAlignment로 양쪽 정렬
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 왼쪽 - 스페셜 오특
                  Text(
                    '스페셜 오특',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppStyles.mainColor,
                    ),
                  ),
                  // 오른쪽 - 시간 표시
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16.sp, color: AppStyles.mainColor),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDuration(_remainingTime), //^ 남은 시간 표시
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppStyles.mainColor,
                        ),
                      ),
                      Text(
                        ' 남음',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppStyles.mainColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // 특가 리스트
        Expanded(
          child: _buildTodaySpecialList(),
        ),
      ],
    );
  }

  Widget _buildTodaySpecialList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      controller: _scrollController,
      itemCount: 10,
      itemBuilder: (context, index) => TodaySaleCardWidget(index: index),
    );
  }
}
