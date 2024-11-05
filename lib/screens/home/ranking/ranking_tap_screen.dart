import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/screens/home/ranking/widgets/ranking_card_widget.dart';
import 'package:onlyveyou/utils/styles.dart';

class RankingTabScreen extends StatefulWidget {
  const RankingTabScreen({Key? key}) : super(key: key);

  @override
  State<RankingTabScreen> createState() => _RankingTabScreenState();
}

class _RankingTabScreenState extends State<RankingTabScreen> {
  String selectedFilter = '전체';

  // 카테고리 필터 리스트만 유지
  final List<String> categoryFilters = [
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 카테고리별 랭킹 텍스트 추가
        Padding(
          padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 8.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '카테고리별 랭킹',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: categoryFilters.map((filter) {
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
          child: _buildRankingList(),
        ),
      ],
    );
  }

  Widget _buildRankingList() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 16.w,
        mainAxisExtent: 340.h,
      ),
      itemCount: 10,
      itemBuilder: (context, index) => RankingCardWidget(index: index),
    );
  }
}
