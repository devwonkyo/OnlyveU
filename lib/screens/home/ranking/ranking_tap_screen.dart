import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/home/ranking_bloc.dart';
import 'package:onlyveyou/repositories/home/ranking_repository.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';
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

  final Map<String, String> _categoryIdMap = {
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

  @override
  void initState() {
    super.initState();
    _rankingBloc = RankingBloc(
      rankingRepository: RankingRepository(),
      cartRepository: ShoppingCartRepository(),
    );
    _rankingBloc.add(LoadRankingProducts());
  }

  @override
  void dispose() {
    _rankingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                  color: isDarkMode ? Colors.white : AppStyles.mainColor,
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

                      if (filter != '전체') {
                        _rankingBloc.add(LoadRankingProducts(
                            categoryId: _categoryIdMap[filter]));
                      } else {
                        _rankingBloc.add(LoadRankingProducts());
                      }
                    },
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.white,
                    selectedColor: AppStyles.mainColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppStyles.mainColor
                            : (isDarkMode
                                ? Colors.grey[600]!
                                : Colors.grey[300]!),
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (isDarkMode ? Colors.white : Colors.black)
                          : (isDarkMode ? Colors.white70 : Colors.grey),
                      fontSize: 14.sp,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _buildRankingList(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList(bool isDarkMode) {
    return BlocBuilder<RankingBloc, RankingState>(
      builder: (context, state) {
        if (state is RankingLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: isDarkMode ? Colors.white : AppStyles.mainColor,
            ),
          );
        } else if (state is RankingLoaded) {
          if (state.products.isEmpty) {
            return Center(
              child: Text(
                '상품이 없습니다.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDarkMode ? Colors.white60 : Colors.grey,
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: isDarkMode ? Colors.white : AppStyles.mainColor,
            onRefresh: () async {
              if (selectedFilter == '전체') {
                _rankingBloc.add(LoadRankingProducts());
              } else {
                _rankingBloc.add(LoadRankingProducts(
                    categoryId: _categoryIdMap[selectedFilter]));
              }
            },
            child: GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24.h,
                crossAxisSpacing: 16.w,
                mainAxisExtent: 380.h,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) => RankingCardWidget(
                index: index,
                product: state.products[index],
              ),
            ),
          );
        } else if (state is RankingError) {
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
                    if (selectedFilter == '전체') {
                      _rankingBloc.add(LoadRankingProducts());
                    } else {
                      _rankingBloc.add(LoadRankingProducts(
                          categoryId: _categoryIdMap[selectedFilter]));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDarkMode ? Colors.white : AppStyles.mainColor,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  ),
                  child: Text('다시 시도'),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
