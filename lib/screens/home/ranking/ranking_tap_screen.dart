import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/styles.dart';

class RankingTabScreen extends StatefulWidget {
  const RankingTabScreen({Key? key}) : super(key: key);

  @override
  State<RankingTabScreen> createState() => _RankingTabScreenState();
}

class _RankingTabScreenState extends State<RankingTabScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 여기에 랭킹 관련 위젯들을 추가할 수 있습니다.
        SliverToBoxAdapter(
          child: Padding(
            padding: AppStyles.defaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '실시간 랭킹',
                  style: AppStyles.headingStyle,
                ),
                SizedBox(height: 16),
                // 추가적인 랭킹 관련 위젯들을 여기에 구현할 수 있습니다.
                Center(
                  child: Text(
                    '랭킹 컨텐츠가 곧 추가될 예정입니다.',
                    style: AppStyles.bodyTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';

// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:onlyveyou/config/color.dart';
//
// class RankingScreen extends StatefulWidget {
//   const RankingScreen({Key? key}) : super(key: key);
//
//   @override
//   State<RankingScreen> createState() => _RankingScreenState();
// }
//
// class _RankingScreenState extends State<RankingScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String selectedFilter = '전체';
//   String selectedSort = '실시간';
//   final List<String> filters = ['전체', '스킨케어', '마스크팩', '클렌징', '색조'];
//   final List<String> sortOptions = ['실시간', '온라인픽', '오늘드림'];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: Column(
//             children: [
//               // 1. Tab Bar
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(color: Colors.grey[300]!, width: 1),
//                   ),
//                 ),
//                 child: TabBar(
//                   controller: _tabController,
//                   tabs: [
//                     Tab(text: '판매 랭킹'),
//                     Tab(text: '브랜드 랭킹'),
//                   ],
//                   labelColor: Colors.black,
//                   unselectedLabelColor: Colors.grey,
//                   indicatorColor: Colors.black,
//                   indicatorWeight: 2,
//                 ),
//               ),
//
//               // 2. Filter Chips
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(vertical: 8.h),
//                 child: Row(
//                   children: filters.map((filter) {
//                     bool isSelected = selectedFilter == filter;
//                     return Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 4.w),
//                       child: FilterChip(
//                         label: Text(filter),
//                         selected: isSelected,
//                         onSelected: (bool selected) {
//                           setState(() {
//                             selectedFilter = filter;
//                           });
//                         },
//                         backgroundColor: Colors.white,
//                         selectedColor: Colors.black.withOpacity(0.1),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                           side: BorderSide(
//                             color:
//                                 isSelected ? Colors.black : Colors.grey[300]!,
//                           ),
//                         ),
//                         labelStyle: TextStyle(
//                           color: isSelected ? Colors.black : Colors.grey,
//                           fontSize: 14.sp,
//                         ),
//                         padding: EdgeInsets.symmetric(horizontal: 12.w),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//
//               // 3. Sort Options and Update Time
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           '29분 전 업데이트',
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 12.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: sortOptions.map((option) {
//                         bool isSelected = selectedSort == option;
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               selectedSort = option;
//                             });
//                           },
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 8.w,
//                               vertical: 4.h,
//                             ),
//                             decoration: BoxDecoration(
//                               border: Border(
//                                 bottom: BorderSide(
//                                   color: isSelected
//                                       ? Colors.black
//                                       : Colors.transparent,
//                                   width: 1,
//                                 ),
//                               ),
//                             ),
//                             child: Text(
//                               option,
//                               style: TextStyle(
//                                 color: isSelected ? Colors.black : Colors.grey,
//                                 fontSize: 14.sp,
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // 4. Ranking List
//               Expanded(
//                 child: TabBarView(
//                   controller: _tabController,
//                   children: [
//                     // 판매 랭킹 탭
//                     _buildRankingList(),
//                     // 브랜드 랭킹 탭
//                     Center(child: Text('브랜드 랭킹 준비중')),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRankingList() {
//     return ListView.separated(
//       padding: EdgeInsets.all(16.w),
//       itemCount: 20, // 예시로 20개 아이템 표시
//       separatorBuilder: (context, index) => SizedBox(height: 16.h),
//       itemBuilder: (context, index) {
//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Ranking Number
//             Container(
//               width: 24.w,
//               height: 24.w,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: index < 3 ? Colors.black : Colors.grey[200],
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 '${index + 1}',
//                 style: TextStyle(
//                   color: index < 3 ? Colors.white : Colors.black,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(width: 12.w),
//
//             // Product Image
//             Container(
//               width: 100.w,
//               height: 100.w,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   image: NetworkImage('https://via.placeholder.com/100'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             SizedBox(width: 12.w),
//
//             // Product Info
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '상품명 예시 ${index + 1}',
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     '50% ${(20000 * (index + 1)).toString()}원',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Row(
//                     children: [
//                       Icon(Icons.star,
//                           size: 16.sp, color: AppsColor.pastelGreen),
//                       SizedBox(width: 4.w),
//                       Text(
//                         '4.8',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(width: 4.w),
//                       Text(
//                         '(999+)',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
