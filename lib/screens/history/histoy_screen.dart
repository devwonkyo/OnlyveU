// history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/screens/history/widgets/history_tap_bar.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';

import '../../blocs/history/history_bloc.dart';
import '../../utils/styles.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

// SingleTickerProviderStateMixin는 애니메이션을 위한 Ticker를 제공
class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // 탭 전환을 관리하는 컨트롤러
  bool isEditing = false; // 편집 모드 상태

  @override
  void initState() {
    super.initState();
    // 탭 컨트롤러 초기화 (2개의 탭)
    _tabController = TabController(length: 2, vsync: this);
    // 히스토리 데이터 로드 요청
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

  // '좋아요한' 탭 내용을 구성하는 위젯
  Widget _buildFavoriteList() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        return Column(
          children: [
            // 상단 필터 섹션 (총 개수, 편집/완료 버튼 등)
            HistoryFilterSection(
              itemCount: state.favoriteItems.length,
              isEditing: isEditing,
              onClearAll: () => context.read<HistoryBloc>().add(ClearHistory()),
              onEditToggle: () => setState(() => isEditing = !isEditing),
              isFavoriteTab: true,
            ),
            // 좋아요한 아이템 목록
            Expanded(
              child: HistoryListView(
                items: state.favoriteItems,
                isEditing: isEditing,
                onDelete: (item) =>
                    context.read<HistoryBloc>().add(RemoveHistoryItem(item)),
                onToggleFavorite: (item) =>
                    context.read<HistoryBloc>().add(ToggleFavorite(item)),
              ),
            ),
          ],
        );
      },
    );
  }

  // '최근 본' 탭 내용을 구성하는 위젯 (구조는 위와 동일)
  Widget _buildRecentList() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        return Column(
          children: [
            HistoryFilterSection(
              itemCount: state.recentItems.length,
              isEditing: isEditing,
              onClearAll: () => context.read<HistoryBloc>().add(ClearHistory()),
              onEditToggle: () => setState(() => isEditing = !isEditing),
              isFavoriteTab: false,
            ),
            Expanded(
              child: HistoryListView(
                items: state.recentItems,
                isEditing: isEditing,
                onDelete: (item) =>
                    context.read<HistoryBloc>().add(RemoveHistoryItem(item)),
                onToggleFavorite: (item) =>
                    context.read<HistoryBloc>().add(ToggleFavorite(item)),
              ),
            ),
          ],
        );
      },
    );
  }
}
