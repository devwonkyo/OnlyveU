import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/screens/history/widgets/history_tap_bar.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';

import '../../blocs/history/history_bloc.dart';
import '../../utils/styles.dart';

// HistoryScreen: 사용자가 본 기록이나 좋아요한 항목을 관리하는 화면
class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

// _HistoryScreenState: HistoryScreen의 상태를 관리하는 클래스
// SingleTickerProviderStateMixin는 애니메이션을 위한 Ticker를 제공
class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // 탭 전환을 관리하는 컨트롤러
  bool isEditing = false; // 편집 모드 여부를 나타내는 변수

  @override
  void initState() {
    super.initState();
    // 탭 컨트롤러 초기화 (2개의 탭: '최근 본'과 '좋아요한' 탭)
    _tabController = TabController(length: 2, vsync: this);
    // 히스토리 데이터를 불러오는 이벤트를 BLoC에 전달
    context.read<HistoryBloc>().add(LoadHistoryItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 앱바
      appBar: DefaultAppBar(mainColor: AppStyles.mainColor),
      body: Column(
        children: [
          // 상단 탭바 ('최근 본'과 '좋아요한' 탭)
          HistoryTabBar(tabController: _tabController),
          // 탭 내용 영역
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecentList(), // '최근 본' 탭 내용
                _buildFavoriteList(), // '좋아요한' 탭 내용
              ],
            ),
          ),
        ],
      ),
    );
  }

  // '좋아요한' 탭의 콘텐츠를 구성하는 함수
  Widget _buildFavoriteList() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      // BLoC 상태에 따라 UI를 구성
      builder: (context, state) {
        return Column(
          children: [
            // 상단 필터 섹션 (총 개수, 편집/완료 버튼 등)
            HistoryFilterSection(
              itemCount: state.favoriteItems.length, // 좋아요한 아이템 개수
              isEditing: isEditing, // 현재 편집 모드인지 여부
              onClearAll: () => context
                  .read<HistoryBloc>()
                  .add(ClearHistory()), // 전체 삭제 이벤트 전달
              onEditToggle: () =>
                  setState(() => isEditing = !isEditing), // 편집 모드 토글
              isFavoriteTab: true, // 좋아요 탭임을 나타냄
            ),
            // 좋아요한 아이템 목록
            Expanded(
              child: HistoryListView(
                items: state.favoriteItems, // 좋아요한 아이템 리스트
                isEditing: isEditing, // 편집 모드 여부 전달
                onDelete: (item) => context
                    .read<HistoryBloc>()
                    .add(RemoveHistoryItem(item)), // 특정 아이템 삭제
                onToggleFavorite: (item) => context
                    .read<HistoryBloc>()
                    .add(ToggleFavorite(item)), // 좋아요 상태 토글
              ),
            ),
          ],
        );
      },
    );
  }

  // '최근 본' 탭의 콘텐츠를 구성하는 함수 (구조는 위와 동일)
  Widget _buildRecentList() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        return Column(
          children: [
            // 최근 본 아이템의 필터 섹션
            HistoryFilterSection(
              itemCount: state.recentItems.length, // 최근 본 아이템 개수
              isEditing: isEditing, // 현재 편집 모드 여부
              onClearAll: () =>
                  context.read<HistoryBloc>().add(ClearHistory()), // 전체 삭제
              onEditToggle: () =>
                  setState(() => isEditing = !isEditing), // 편집 모드 토글
              isFavoriteTab: false, // 좋아요 탭이 아님
            ),
            // 최근 본 아이템 목록
            Expanded(
              child: HistoryListView(
                items: state.recentItems, // 최근 본 아이템 리스트
                isEditing: isEditing, // 편집 모드 여부 전달
                onDelete: (item) => context
                    .read<HistoryBloc>()
                    .add(RemoveHistoryItem(item)), // 특정 아이템 삭제
                onToggleFavorite: (item) => context
                    .read<HistoryBloc>()
                    .add(ToggleFavorite(item)), // 좋아요 상태 토글
              ),
            ),
          ],
        );
      },
    );
  }
}
