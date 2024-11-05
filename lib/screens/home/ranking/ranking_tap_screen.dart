// 4. ranking_tap_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/home/ranking_bloc.dart';
import 'package:onlyveyou/repositories/product_repository.dart';
import 'package:onlyveyou/screens/home/ranking/widgets/ranking_card_widget.dart';
import 'package:onlyveyou/utils/styles.dart';

class RankingTabScreen extends StatefulWidget {
  const RankingTabScreen({Key? key}) : super(key: key);

  @override
  State<RankingTabScreen> createState() => _RankingTabScreenState();
}

class _RankingTabScreenState extends State<RankingTabScreen> {
  String selectedFilter = '전체';
  late RankingBloc _rankingBloc;

  // 카테고리명과 ID 매핑
  final Map<String, String> categoryIdMap = {
    '전체': 'all',
    '스킨케어': '1',
    '마스크팩': '2',
    '클렌징': '3',
    '선케어': '4',
    '메이크업': '5',
    '뷰티소품': '6',
    '맨즈케어': '7',
    '헤어케어': '8',
    '바디케어': '9',
  };

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
  void initState() {
    super.initState();
    _rankingBloc = RankingBloc(productRepository: ProductRepository());
    _rankingBloc.add(LoadRankingProducts());
  }

  @override
  void dispose() {
    _rankingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _rankingBloc,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 8.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '카테고리별 랭킹',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.mainColor,
                ),
              ),
            ),
          ),
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
                      _rankingBloc.add(LoadRankingProducts(category: filter));
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppStyles.mainColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppStyles.mainColor
                            : Colors.grey[300]!,
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
          Expanded(
            child: BlocBuilder<RankingBloc, RankingState>(
              builder: (context, state) {
                if (state is RankingLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is RankingLoaded) {
                  return GridView.builder(
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 28.h,
                      crossAxisSpacing: 16.w,
                      mainAxisExtent: 340.h,
                    ),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) => RankingCardWidget(
                      index: index,
                      product: state.products[index],
                    ),
                  );
                } else if (state is RankingError) {
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
}
