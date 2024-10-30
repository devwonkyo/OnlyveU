// // lib/presentation/screens/history_screen.dart
// import 'package:flutter/material.dart';
//
// class HistoryScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('히스토리 화면'));
//   }
// }
// history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/screens/history/widgets/history_tap_bar.dart';

import '../../blocs/history/history_bloc.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<HistoryBloc>().add(LoadHistoryItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('히스토리'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
          ),
          TextButton(
            child: Text(isEditing ? '완료' : '편집'),
            onPressed: () => setState(() => isEditing = !isEditing),
          ),
        ],
      ),
      body: Column(
        children: [
          HistoryTabBar(tabController: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecentList(),
                _buildFavoriteList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentList() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        return Column(
          children: [
            HistoryFilterSection(
              itemCount: state.recentItems.length,
              isEditing: isEditing,
              onClearAll: () => context.read<HistoryBloc>().add(ClearHistory()),
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

  Widget _buildFavoriteList() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        return Column(
          children: [
            HistoryFilterSection(
              itemCount: state.favoriteItems.length,
              isEditing: isEditing,
              onClearAll: () => context.read<HistoryBloc>().add(ClearHistory()),
            ),
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
}
