import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/home/ranking_bloc.dart';
import 'package:onlyveyou/repositories/home/ranking_repository.dart';
import 'package:onlyveyou/screens/home/ranking/widgets/ranking_card_widget.dart';
import 'package:onlyveyou/utils/styles.dart';

class RankingTabScreen extends StatefulWidget {
  const RankingTabScreen({Key? key}) : super(key: key);

  @override
  State<RankingTabScreen> createState() => _RankingTabScreenState();
}

class _RankingTabScreenState extends State<RankingTabScreen> {
  String selectedFilter = '전체'; // 선택된 카테고리 필터
  late RankingBloc _rankingBloc; // 랭킹 상품을 로드하기 위한 Bloc 인스턴스

  // 카테고리 필터 목록
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

  // 카테고리 이름과 ID 매핑
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
    _rankingBloc =
        RankingBloc(rankingRepository: RankingRepository()); // Bloc 초기화
    _rankingBloc.add(LoadRankingProducts()); // 전체 랭킹 상품 로드
  }

  @override
  void dispose() {
    _rankingBloc.close(); // Bloc 자원 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _rankingBloc,
      child: Column(
        children: [
          // 화면 상단의 '카테고리별 랭킹' 텍스트
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
          // 카테고리 필터 목록 (수평 스크롤)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              children: categoryFilters.map((filter) {
                bool isSelected = selectedFilter == filter; // 필터 선택 여부
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedFilter = filter;
                      });

                      // 선택된 카테고리에 따라 이벤트 발생
                      if (filter != '전체') {
                        _rankingBloc.add(LoadRankingProducts(
                            categoryId: _categoryIdMap[filter]));
                      } else {
                        _rankingBloc.add(LoadRankingProducts());
                      }
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
          // 랭킹 상품 리스트 표시
          Expanded(
            child: _buildRankingList(),
          ),
        ],
      ),
    );
  }

  // 랭킹 상품 리스트를 빌드하는 메서드
  Widget _buildRankingList() {
    return BlocBuilder<RankingBloc, RankingState>(
      builder: (context, state) {
        if (state is RankingLoading) {
          // 로딩 상태 표시
          return Center(
            child: CircularProgressIndicator(
              color: AppStyles.mainColor,
            ),
          );
        } else if (state is RankingLoaded) {
          // 랭킹 상품 로드 완료 상태
          if (state.products.isEmpty) {
            // 상품이 없을 때 메시지 표시
            return Center(
              child: Text(
                '상품이 없습니다.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            );
          }
          // 상품 목록을 그리드 뷰로 표시
          return RefreshIndicator(
            color: AppStyles.mainColor,
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
                mainAxisExtent: 340.h,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) => RankingCardWidget(
                index: index,
                product: state.products[index],
              ),
            ),
          );
        } else if (state is RankingError) {
          // 오류 상태일 때 오류 메시지와 다시 시도 버튼 표시
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    // 현재 선택된 필터에 따라 이벤트 발생
                    if (selectedFilter == '전체') {
                      _rankingBloc.add(LoadRankingProducts());
                    } else {
                      _rankingBloc.add(LoadRankingProducts(
                          categoryId: _categoryIdMap[selectedFilter]));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.mainColor,
                  ),
                  child: Text('다시 시도'),
                ),
              ],
            ),
          );
        }
        return Container(); // 기본 상태
      },
    );
  }
}
