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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                        '02:51:47',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppStyles.mainColor,
                        ),
                      ),
                      Text(
                        ' 분후',
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
