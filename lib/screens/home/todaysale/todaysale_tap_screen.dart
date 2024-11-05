import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/utils/styles.dart';

class TodaySaleTabScreen extends StatefulWidget {
  const TodaySaleTabScreen({Key? key}) : super(key: key);

  @override
  State<TodaySaleTabScreen> createState() => _TodaySaleTabScreenState();
}

class _TodaySaleTabScreenState extends State<TodaySaleTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Theme(
          data: Theme.of(context).copyWith(
            tabBarTheme: TabBarTheme(
              indicator:
                  BoxDecoration(color: Colors.transparent), // 인디케이터 투명 처리 //^
              dividerColor: Colors.transparent, // 기본 검은색 테두리 제거 //^
              overlayColor: MaterialStateProperty.all(
                  Colors.transparent), // 터치시 오버레이 색상 제거 //^
            ),
          ),
          child: Container(
            color: Colors.white, // 배경색을 흰색으로 설정 //^
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: '오늘의 특가'),
                Tab(text: '위클리 특가'),
              ],
              labelColor: AppStyles.mainColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.transparent, // 인디케이터 색상 투명 //^
              indicatorWeight: 0.1, // 인디케이터 두께 0 //^
            ),
          ),
        ),

        // Tab Bar View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTodaySpecialList(),
              _buildWeeklySpecialList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySpecialList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 10, // 임시 데이터
      itemBuilder: (context, index) {
        return _buildSpecialItem(index, "오늘의 특가");
      },
    );
  }

  Widget _buildWeeklySpecialList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 10, // 임시 데이터
      itemBuilder: (context, index) {
        return _buildSpecialItem(index, "위클리 특가");
      },
    );
  }

  Widget _buildSpecialItem(int index, String type) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/100'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // 상품 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 특가 타입 태그
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppsColor.pastelGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: AppsColor.pastelGreen,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // 상품명
                  Text(
                    '특가 상품 ${index + 1}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // 가격 정보
                  Row(
                    children: [
                      Text(
                        '50%',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${(20000 * (index + 1)).toString()}원',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // 리뷰 정보
                  Row(
                    children: [
                      Icon(Icons.star,
                          size: 16.sp, color: AppsColor.pastelGreen),
                      SizedBox(width: 4.w),
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(999+)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
