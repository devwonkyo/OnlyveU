import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/history/history_bloc.dart';
import 'package:onlyveyou/screens/history/widgets/history_item_card.dart';

import '../../../models/history_item.dart';

// 1. 상단 탭바 위젯
class HistoryTabBar extends StatelessWidget {
  // TabController를 통해 탭 전환을 관리
  final TabController tabController;

  const HistoryTabBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      tabs: [
        // 첫 번째 탭: '최근 본'
        Tab(
          child: Text(
            '최근 본',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // 두 번째 탭: '좋아요한'
        Tab(
          child: Text(
            '좋아요한',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      labelColor: Color(0xFFC9C138), // 선택된 탭의 색상
      unselectedLabelColor: Colors.grey, // 선택되지 않은 탭의 색상
      indicatorColor: Color(0xFFC9C138), // 탭 아래 표시되는 인디케이터 색상
    );
  }
}

// 2. 필터 섹션 위젯 (아이템 개수 표시 및 편집 버튼 포함)
class HistoryFilterSection extends StatelessWidget {
  final int itemCount; // 표시할 아이템 개수
  final bool isEditing; // 편집 모드 여부
  final VoidCallback onClearAll; // 전체 삭제 버튼 클릭 시 실행할 함수
  final VoidCallback onEditToggle; // 편집 버튼 클릭 시 실행할 함수
  final bool isFavoriteTab; // 현재 탭이 좋아요 탭인지 여부

  const HistoryFilterSection({
    required this.itemCount,
    required this.isEditing,
    required this.onClearAll,
    required this.onEditToggle,
    this.isFavoriteTab = false,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = Color(0xFFC9C138); // 앱의 메인 색상

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측: 아이템 개수 표시
          // 좋아요 탭일 경우 실시간으로 좋아요 개수 업데이트
          isFavoriteTab
              ? BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    int favoriteCount = state.favoriteItems.length;
                    // RichText를 사용하여 텍스트의 일부분만 다른 스타일 적용
                    return RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: '좋아요 ',
                            style: TextStyle(color: mainColor),
                          ),
                          TextSpan(
                            text: favoriteCount.toString(),
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextSpan(
                            text: '개',
                            style: TextStyle(color: mainColor),
                          ),
                        ],
                      ),
                    );
                  },
                )
              // 최근 본 탭의 경우
              : RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '총 ',
                        style: TextStyle(color: mainColor),
                      ),
                      TextSpan(
                        text: itemCount.toString(),
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextSpan(
                        text: '개',
                        style: TextStyle(color: mainColor),
                      ),
                    ],
                  ),
                ),

          // 우측: 편집/완료 버튼
          Row(
            children: [
              // 편집 모드일 때만 전체삭제 버튼 표시
              if (isEditing)
                TextButton(
                  onPressed: onClearAll,
                  style: TextButton.styleFrom(
                    foregroundColor: mainColor,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    '전체삭제',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              // 편집/완료 토글 버튼
              TextButton(
                onPressed: onEditToggle,
                style: TextButton.styleFrom(
                  foregroundColor: mainColor,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  isEditing ? '완료' : '편집',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 3. 히스토리 리스트 표시 위젯
class HistoryListView extends StatelessWidget {
  final List<HistoryItem> items; // 표시할 아이템 목록
  final bool isEditing; // 편집 모드 여부
  final Function(HistoryItem) onDelete; // 삭제 콜백
  final Function(HistoryItem) onToggleFavorite; // 좋아요 토글 콜백

  const HistoryListView({
    required this.items,
    required this.isEditing,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    // ListView.builder를 사용하여 효율적으로 목록 표시
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return HistoryItemCard(
          item: items[index],
          isEditing: isEditing,
          onDelete: () => onDelete(items[index]),
          onToggleFavorite: () => onToggleFavorite(items[index]),
        );
      },
    );
  }
}
