import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/utils/styles.dart';

class RankingTabScreen extends StatefulWidget {
  const RankingTabScreen({Key? key}) : super(key: key);

  @override
  State<RankingTabScreen> createState() => _RankingTabScreenState();
}

class _RankingTabScreenState extends State<RankingTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = '전체';
  String selectedSort = '실시간';
  final List<String> filters = [
    '전체',
    '스킨케어',
    '마스크팩',
    '클렌징',
    '선케어',
    '메이크업',
    '뷰티소품',
    '맨즈케어',
    '헤어케어',
    '바디케어'
  ];
  final List<String> sortOptions = ['실시간', '온라인픽', '오늘드림'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Tab Bar
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
                Tab(text: '판매 랭킹'),
                Tab(text: '브랜드 랭킹'),
              ],
              labelColor: AppStyles.mainColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.transparent, // 인디케이터 색상 투명 //^
              indicatorWeight: 0.1, // 인디케이터 두께 0 //^
            ),
          ),
        ),

        // 2. Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: filters.map((filter) {
              bool isSelected = selectedFilter == filter;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey,
                    fontSize: 14.sp,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
              );
            }).toList(),
          ),
        ),

        // 4. Ranking List with TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 판매 랭킹 탭
              _buildRankingList(),
              // 브랜드 랭킹 탭
              Center(child: Text('브랜드 랭킹 준비중')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingList() {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 20, // 예시로 20개 아이템 표시
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ranking Number
            Container(
              width: 24.w,
              height: 24.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: index < 3 ? Colors.black : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: index < 3 ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Product Image
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

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '상품명 예시 ${index + 1}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '50% ${(20000 * (index + 1)).toString()}원',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
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
        );
      },
    );
  }
}
