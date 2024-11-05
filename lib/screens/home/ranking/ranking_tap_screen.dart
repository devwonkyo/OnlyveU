import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                  }, //AppStyles.mainColor.withOpacity(0.1),
                  backgroundColor: Colors.white,
                  selectedColor: AppStyles.mainColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color:
                          isSelected ? AppStyles.mainColor : Colors.grey[300]!,
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
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.h, // 16.h에서 8.h로 수정
        crossAxisSpacing: 16.w, // 가로 간격은 유지
        mainAxisExtent: 340.h, // 400.h에서 340.h로 수정하여 카드 높이를 줄임
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          // height를 지정하지 않아 내용물 크기에 맞춰 자동 조절
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // 상품 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://via.placeholder.com/100',
                      width: double.infinity,
                      height: 180.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, size: 180.h),
                    ),
                  ),
                  // 순위 표시
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            index < 3 ? AppStyles.mainColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 나머지 내용들...
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '인기 상품 ${index + 1}',
                      style: TextStyle(
                        fontSize: 14.sp,
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
                          '38%',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '61,520원',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 16.sp, color: AppStyles.mainColor),
                        SizedBox(width: 4.w),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '(6,817)',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 20.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 20.sp,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
