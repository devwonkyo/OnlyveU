// todaysale_tab_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/todaysale_bloc.dart';
import 'package:onlyveyou/repositories/home/today_sale_repository.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/utils/styles.dart';

class TodaySaleTabScreen extends StatefulWidget {
  const TodaySaleTabScreen({Key? key}) : super(key: key);

  @override
  State<TodaySaleTabScreen> createState() => _TodaySaleTabScreenState();
}

class _TodaySaleTabScreenState extends State<TodaySaleTabScreen> {
  final ScrollController _scrollController =
      ScrollController(); // 상품 목록 스크롤을 위한 컨트롤러
  late Timer _timer; // 남은 시간 타이머
  Duration _remainingTime = Duration.zero; // 남은 시간 초기화
  late TodaySaleBloc _todaySaleBloc; // 오늘의 특가 상품을 위한 Bloc

  @override
  void initState() {
    super.initState();
    _todaySaleBloc = TodaySaleBloc(
      repository: TodaySaleRepository(),
      cartRepository: ShoppingCartRepository(), // 추가
    );
    _calculateRemainingTime();
    _startTimer();
    _todaySaleBloc.add(LoadTodaySaleProducts());
  }

  // 남은 시간을 자정 또는 다음 자정 기준으로 계산하는 메서드
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

  // 디버그용 남은 시간을 짧게 설정하는 메서드 (현재 주석 처리)
  /*
  void _calculateRemainingTime() {
    final now = DateTime.now().add(Duration(hours: 9));
    final currentMinute = now.minute;
    final nextInterval = ((currentMinute / 3).ceil() * 3) % 60;
    final targetTime = DateTime(now.year, now.month, now.day, now.hour, nextInterval, 0);

    if (now.isBefore(targetTime)) {
      _remainingTime = targetTime.difference(now);
    } else {
      final nextTime = targetTime.add(Duration(minutes: 3));
      _remainingTime = nextTime.difference(now);
    }
    print('다음 갱신 시간까지: ${_formatDuration(_remainingTime)}');
  }
  */

  // 1초마다 남은 시간을 갱신하며 타이머를 관리하는 메서드
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return; // widget이 mounted 상태인지 확인하여 경고 방지
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - Duration(seconds: 1);
        } else {
          _todaySaleBloc.add(ShuffleProducts()); // 시간이 0이 되면 상품 목록을 섞음
          _calculateRemainingTime(); // 다음 타이머 시간을 계산
        }
      });
    });
  }

  // 화면이 사라질 때 타이머와 Bloc 자원을 해제하는 메서드
  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel(); // 타이머가 활성화되어 있으면 해제
    }
    _scrollController.dispose(); // 스크롤 컨트롤러 해제
    _todaySaleBloc.close(); // Bloc 해제
    super.dispose();
  }

  // Duration 타입의 시간을 시, 분, 초 형식으로 변환하는 메서드
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _todaySaleBloc,
      child: Column(
        children: [
          // 상단 타이머와 할인율 정보 표시
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
          // 상품 리스트 영역
          Expanded(
            child: BlocBuilder<TodaySaleBloc, TodaySaleState>(
              builder: (context, state) {
                if (state is TodaySaleLoading) {
                  return Center(child: CircularProgressIndicator()); // 로딩 상태
                } else if (state is TodaySaleLoaded) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    controller: _scrollController,
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return GestureDetector(
                        onTap: () => context.push('/product-detail',
                            extra: product.productId),
                        child: Container(
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
                              // 상품 이미지 표시 (비어있으면 기본 아이콘 표시)
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
                                    // 상품명 표시
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
                                    // 원래 가격 (취소선 표시)
                                    Text(
                                      '${product.price}원',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    // 할인된 가격 표시
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
                                    // BEST 태그 표시
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        if (product.isPopular)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '인기',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        if (product.isPopular && product.isBest)
                                          SizedBox(width: 6.w),
                                        if (product.isBest)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'BEST',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    // 평점 및 리뷰 수 표시
                                    Row(
                                      children: [
                                        Icon(Icons.star,
                                            size: 13.sp,
                                            color: AppStyles.mainColor),
                                        SizedBox(width: 4.w),
                                        Text(
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
                              // 찜하기와 장바구니 아이콘 표시
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20.h),
                                  FutureBuilder<String>(
                                    future: OnlyYouSharedPreference()
                                        .getCurrentUserId(),
                                    builder: (context, snapshot) {
                                      final userId =
                                          snapshot.data ?? 'temp_user_id';
                                      return GestureDetector(
                                        onTap: () {
                                          print(
                                              'TodaySale Product ID: ${product.productId}'); // I작업 추가
                                          context.read<TodaySaleBloc>().add(
                                                ToggleProductFavorite(
                                                    product, userId),
                                              );
                                        },
                                        child: Icon(
                                          product.favoriteList.contains(userId)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 24.sp,
                                          color: product.favoriteList
                                                  .contains(userId)
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 25.h),
                                  GestureDetector(
                                    onTap: () async {
                                      context
                                          .read<TodaySaleBloc>()
                                          .add(AddToCart(product.productId));

                                      context
                                          .read<TodaySaleBloc>()
                                          .stream
                                          .listen(
                                        (state) {
                                          if (state is TodaySaleError ||
                                              state is TodaySaleSuccess) {
                                            ScaffoldMessenger.of(context)
                                                .clearSnackBars();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(state
                                                        is TodaySaleSuccess
                                                    ? state.message
                                                    : (state as TodaySaleError)
                                                        .message),
                                                duration: Duration(
                                                    milliseconds: 1000),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      child: Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is TodaySaleError) {
                  return Center(child: Text(state.message)); // 오류 메시지 표시
                }
                return Container(); // 기본 상태
              },
            ),
          ),
        ],
      ),
    );
  }

  // 할인된 가격 계산 메서드
  String _calculateDiscountedPrice(String originalPrice, int discountPercent) {
    final price = int.parse(originalPrice.replaceAll(',', ''));
    final discountedPrice = price - (price * (discountPercent / 100)).round();
    return discountedPrice.toString();
  }
}
