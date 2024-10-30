// widgets/history_tab_bar.dart

import 'package:flutter/material.dart';
import 'package:onlyveyou/screens/history/widgets/history_item_card.dart';

import '../../../models/history_item.dart';

class HistoryTabBar extends StatelessWidget {
  final TabController tabController;

  const HistoryTabBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      tabs: [
        Tab(text: '최근 본'),
        Tab(text: '좋아요한'),
      ],
    );
  }
}

// widgets/history_filter_section.dart
class HistoryFilterSection extends StatelessWidget {
  final int itemCount;
  final bool isEditing;
  final VoidCallback onClearAll;

  const HistoryFilterSection({
    required this.itemCount,
    required this.isEditing,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('총 $itemCount개'),
          Spacer(),
          TextButton(
            child: Text('전체삭제'),
            onPressed: isEditing ? onClearAll : null,
          ),
        ],
      ),
    );
  }
}

// widgets/history_list_view.dart
class HistoryListView extends StatelessWidget {
  final List<HistoryItem> items;
  final bool isEditing;
  final Function(HistoryItem) onDelete;
  final Function(HistoryItem) onToggleFavorite;

  const HistoryListView({
    required this.items,
    required this.isEditing,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
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
