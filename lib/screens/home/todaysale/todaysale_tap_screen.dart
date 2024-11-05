import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                    '인기',
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
                        '분후',
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
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: 16.w, vertical: 12.w), // vertical padding 줄임
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
              // 1. 상품 이미지 부분
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://via.placeholder.com/100',
                  width: 120.w,
                  height: 120.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image, size: 120.w),
                ),
              ),
              SizedBox(width: 16.w),

              // 2. 상품 정보 부분
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '특가 상품 ${index + 1}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '99,900원',
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '50%',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '49,900원',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppStyles.mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "스페셜 오특",
                        style: TextStyle(
                          color: AppStyles.mainColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 16.sp, color: AppStyles.mainColor),
                        SizedBox(width: 4.w),
                        Text(
                          '4.7',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '(26,152)',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. 좋아요와 장바구니 아이콘을 오른쪽 상단에 배치
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
  }
}
