import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/history/history_bloc.dart';
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
        Tab(
          child: Text(
            '최근 본',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
      labelColor: Color(0xFFC9C138),
      unselectedLabelColor: Colors.grey,
      indicatorColor: Color(0xFFC9C138),
    );
  }
}

class HistoryFilterSection extends StatelessWidget {
  final int itemCount;
  final bool isEditing;
  final VoidCallback onClearAll;
  final VoidCallback onEditToggle;
  final bool isFavoriteTab;

  const HistoryFilterSection({
    required this.itemCount,
    required this.isEditing,
    required this.onClearAll,
    required this.onEditToggle,
    this.isFavoriteTab = false,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = Color(0xFFC9C138);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isFavoriteTab
              ? BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    int favoriteCount = state.favoriteItems.length;
                    return RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: '좋아요 ',
                            style: TextStyle(
                              color: mainColor,
                            ),
                          ),
                          TextSpan(
                            text: favoriteCount.toString(),
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          TextSpan(
                            text: '개',
                            style: TextStyle(
                              color: mainColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '총 ',
                        style: TextStyle(
                          color: mainColor,
                        ),
                      ),
                      TextSpan(
                        text: itemCount.toString(),
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text: '개',
                        style: TextStyle(
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                ),
          Row(
            children: [
              if (isEditing)
                TextButton(
                  onPressed: onClearAll,
                  style: TextButton.styleFrom(
                    foregroundColor: mainColor,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    '전체삭제',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              TextButton(
                onPressed: onEditToggle,
                style: TextButton.styleFrom(
                  foregroundColor: mainColor,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  isEditing ? '완료' : '편집',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
