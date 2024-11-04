import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/history/history_bloc.dart';
import 'package:onlyveyou/screens/history/widgets/history_item_card.dart'; // 히스토리 아이템 카드 위젯

import '../../../models/history_item.dart';

// 1. 상단 탭바 위젯: '최근 본'과 '좋아요한' 탭을 제공
class HistoryTabBar extends StatelessWidget {
  final TabController tabController; // 탭 전환을 관리하는 컨트롤러
  const HistoryTabBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController, // 전달받은 탭 컨트롤러
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
      //선택된거 메인칼러 나오도록, 선택안된건 회색
      labelColor: Color(0xFFC9C138),
      unselectedLabelColor: Colors.grey,
      indicatorColor: Color(0xFFC9C138), // 탭 아래 표시되는 인디케이터 색상-작대기
    );
  }
}

// 2.총 몇개 개수 설정
class HistoryFilterSection extends StatelessWidget {
  final int itemCount; // 현재 탭에 표시할 아이템 개수
  final bool isEditing; // 현재 편집 모드 여부
  final VoidCallback onClearAll; // 전체 삭제 버튼을 클릭했을 때 실행할 함수-내부저장함수
  final VoidCallback onEditToggle; // 편집 버튼을 클릭했을 때 실행할 함수
  final bool isFavoriteTab; // 좋아요 탭 여부

  const HistoryFilterSection({
    required this.itemCount,
    required this.isEditing,
    required this.onClearAll,
    required this.onEditToggle,
    this.isFavoriteTab = false,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = Color(0xFFC9C138); // 메인 색상

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우로 배치
        children: [
          // 좌측: 아이템 개수 표시
          isFavoriteTab // 좋아요 탭인지 여부 확인
              ? BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    int favoriteCount =
                        state.favoriteItems.length; // 좋아요한 아이템 수
                    // RichText를 사용하여 일부 텍스트 스타일을 다르게 설정
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
              // 편집 모드일 때만 전체 삭제 버튼 표시
              if (isEditing)
                TextButton(
                  onPressed: onClearAll, // 전체 삭제 함수 호출
                  style: TextButton.styleFrom(
                    foregroundColor: mainColor,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    '전체삭제', // 버튼 텍스트
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              // 편집/완료 토글 버튼
              TextButton(
                onPressed: onEditToggle, // 편집 모드 토글
                style: TextButton.styleFrom(
                  foregroundColor: mainColor,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  isEditing ? '완료' : '편집', // 편집 중일 경우 '완료', 아닐 경우 '편집'
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

// 3. 히스토리 리스트 표시 위젯: 아이템 목록을 보여주는 위젯
class HistoryListView extends StatelessWidget {
  final List<HistoryItem> items; // 히스토리 아이템 리스트
  final bool isEditing; // 편집 모드 여부
  final Function(HistoryItem) onDelete; // 아이템 삭제 콜백
  final Function(HistoryItem) onToggleFavorite; // 좋아요 상태 토글 콜백

  const HistoryListView({
    required this.items,
    required this.isEditing,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    // ListView.builder를 사용하여 아이템 목록을 효율적으로 표시
    return ListView.builder(
      itemCount: items.length, // 아이템 수
      itemBuilder: (context, index) {
        return HistoryItemCard(
          item: items[index], // 히스토리 아이템 카드에 아이템 전달
          isEditing: isEditing, // 편집 모드 여부 전달
          onDelete: () => onDelete(items[index]), // 삭제 함수 호출
          onToggleFavorite: () =>
              onToggleFavorite(items[index]), // 좋아요 토글 함수 호출
        );
      },
    );
  }
}
