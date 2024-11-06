// todaysale_tab_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/home/todaysale_bloc.dart';
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
  late TodaySaleBloc _todaySaleBloc;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
    _todaySaleBloc = TodaySaleBloc();
    _todaySaleBloc.add(LoadTodaySaleProducts());
  }

  void _calculateRemainingTime() {
    final now = DateTime.now().add(Duration(hours: 9)); // 한국 시간으로 보정
    final todayMidnight =
        DateTime(now.year, now.month, now.day, 24, 0); // 오늘 밤 12시
    final tomorrowMidnight = todayMidnight.add(Duration(days: 1)); // 내일 밤 12시

    if (now.isBefore(todayMidnight)) {
      _remainingTime = todayMidnight.difference(now);
    } else {
      _remainingTime = tomorrowMidnight.difference(now);
    }
  }

  // //3분씩 디버그용
  // void _calculateRemainingTime() {
  //   final now = DateTime.now().add(Duration(hours: 9)); // 한국 시간
  //
  //   // 테스트를 위해 더 짧은 간격 설정 (예: 3분 간격)
  //   final currentMinute = now.minute;
  //   final nextInterval = ((currentMinute / 3).ceil() * 3) % 60;
  //
  //   final targetTime = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //     now.hour,
  //     nextInterval,
  //     0, // 초는 0으로
  //   );
  //
  //   if (now.isBefore(targetTime)) {
  //     _remainingTime = targetTime.difference(now);
  //   } else {
  //     // 다음 3분 간격
  //     final nextTime = targetTime.add(Duration(minutes: 3));
  //     _remainingTime = nextTime.difference(now);
  //   }
  //
  //   print('다음 갱신 시간까지: ${_formatDuration(_remainingTime)}');
  // }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return; // mounted 체크 추가 -노란 경고 때문
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - Duration(seconds: 1);
        } else {
          _todaySaleBloc.add(ShuffleProducts());
          _calculateRemainingTime(); // 시간이 0이 되면 다음 타이머 시간 계산

          /// 시간이 0이 되면 다음 타이머 시간 계산
        }
      });
    });
  }

  @override //노란색 경고 때문에
  void dispose() {
    if (_timer.isActive) {
      // Timer가 활성화되어 있는지 확인
      _timer.cancel();
    }
    _scrollController.dispose();
    _todaySaleBloc.close();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
  // ... [기존의 timer 관련 메서드들은 유지]

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _todaySaleBloc,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '40% 이상 할인',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppStyles.mainColor,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16.sp, color: AppStyles.mainColor),
                        SizedBox(width: 4.w),
                        Text(
                          _formatDuration(_remainingTime),
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
          Expanded(
            child: BlocBuilder<TodaySaleBloc, TodaySaleState>(
              builder: (context, state) {
                if (state is TodaySaleLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is TodaySaleLoaded) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    controller: _scrollController,
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.w),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product.productImageList.isNotEmpty
                                  ? Image.network(
                                      product.productImageList.first,
                                      width: 120.w,
                                      height: 120.w,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 120.w,
                                        height: 120.w,
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 40.w,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      // productImageList가 비어있을 때 보여줄 기본 컨테이너
                                      width: 120.w,
                                      height: 120.w,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 40.w,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${product.price}원',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Text(
                                        '${product.discountPercent}%',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '${_calculateDiscountedPrice(product.price, product.discountPercent)}원',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (product.isBest) ...[
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: AppStyles.mainColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "BEST",
                                        style: TextStyle(
                                          color: AppStyles.mainColor,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          size: 13.sp,
                                          color: AppStyles.mainColor),
                                      SizedBox(width: 4.w),
                                      Text(
                                        // rating을 소수점 1자리까지만 표시하도록 수정
                                        product.rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '(${product.reviewList.length})',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 20.h),
                                Icon(
                                  Icons.favorite_border,
                                  size: 24.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 25.h),
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 24.sp,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is TodaySaleError) {
                  return Center(child: Text(state.message));
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDiscountedPrice(String originalPrice, int discountPercent) {
    final price = int.parse(originalPrice.replaceAll(',', ''));
    final discountedPrice = price - (price * (discountPercent / 100)).round();
    return discountedPrice.toString();
  }
}
