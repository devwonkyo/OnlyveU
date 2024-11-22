import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/todaysale_bloc.dart';
import 'package:onlyveyou/repositories/home/today_sale_repository.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';
import 'package:onlyveyou/utils/format_price.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
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
    _todaySaleBloc = TodaySaleBloc(
      repository: TodaySaleRepository(),
      cartRepository: ShoppingCartRepository(),
    );
    _calculateRemainingTime();
    _startTimer();
    _todaySaleBloc.add(LoadTodaySaleProducts());
  }

  void _calculateRemainingTime() {
    final now = DateTime.now().add(Duration(hours: 9));
    final todayMidnight = DateTime(now.year, now.month, now.day, 24, 0);
    final tomorrowMidnight = todayMidnight.add(Duration(days: 1));

    if (now.isBefore(todayMidnight)) {
      _remainingTime = todayMidnight.difference(now);
    } else {
      _remainingTime = tomorrowMidnight.difference(now);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - Duration(seconds: 1);
        } else {
          _todaySaleBloc.add(ShuffleProducts());
          _calculateRemainingTime();
        }
      });
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                      color: isDarkMode ? Colors.white : Colors.black,
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
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDarkMode ? Colors.white : AppStyles.mainColor,
                    ),
                  );
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
                                color: isDarkMode
                                    ? Colors.grey[800]!
                                    : Colors.grey[200]!,
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
                                          color: isDarkMode
                                              ? Colors.grey[800]
                                              : Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 40.w,
                                            color: isDarkMode
                                                ? Colors.grey[600]
                                                : Colors.grey[400],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 120.w,
                                        height: 120.w,
                                        color: isDarkMode
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 40.w,
                                          color: isDarkMode
                                              ? Colors.grey[600]
                                              : Colors.grey[400],
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
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '${formatPrice(product.price)}원',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey,
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
                                          '${formatDiscountedPriceToString(product.price, product.discountPercent.toDouble())}원',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        if (product.isPopular)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.grey[800]
                                                  : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '인기',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87,
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
                                              color: isDarkMode
                                                  ? Colors.grey[800]
                                                  : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'BEST',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
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
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '(${product.reviewList.length})',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey,
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
                                  FutureBuilder<String>(
                                    future: OnlyYouSharedPreference()
                                        .getCurrentUserId(),
                                    builder: (context, snapshot) {
                                      final userId =
                                          snapshot.data ?? 'temp_user_id';
                                      return GestureDetector(
                                        onTap: () {
                                          print(
                                              'TodaySale Product ID: ${product.productId}');
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
                                              : (isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey),
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
                                                content: Text(
                                                  state is TodaySaleSuccess
                                                      ? state.message
                                                      : (state
                                                              as TodaySaleError)
                                                          .message,
                                                ),
                                                backgroundColor: isDarkMode
                                                    ? Colors.grey[800]
                                                    : null,
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
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey,
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isDarkMode ? Colors.white60 : Colors.grey,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            _todaySaleBloc.add(LoadTodaySaleProducts());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDarkMode ? Colors.white : AppStyles.mainColor,
                            foregroundColor:
                                isDarkMode ? Colors.black : Colors.white,
                          ),
                          child: Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
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
