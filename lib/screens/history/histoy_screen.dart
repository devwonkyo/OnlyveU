import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/screens/history/widgets/history_tap_bar.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';

import '../../blocs/history/history_bloc.dart';
import '../../utils/styles.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isEditing = false;
  final _prefs = OnlyYouSharedPreference();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final historyBloc = context.read<HistoryBloc>();
    if (historyBloc.state.recentItems.isEmpty) {
      historyBloc.add(LoadHistoryItems());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(mainColor: AppStyles.mainColor),
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

  Widget _buildFavoriteList() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        return Column(
          children: [
            HistoryFilterSection(
              itemCount: state.favoriteItems.length,
              isEditing: isEditing,
              onClearAll: () => context.read<HistoryBloc>().add(ClearHistory()),
              onEditToggle: () => setState(() => isEditing = !isEditing),
              isFavoriteTab: true,
            ),
            Expanded(
              child: HistoryListView(
                items: state.favoriteItems,
                isEditing: isEditing,
                onDelete: (product) =>
                    context.read<HistoryBloc>().add(RemoveHistoryItem(product)),
                onToggleFavorite: (product) async {
                  final userId = await _prefs.getCurrentUserId();
                  context
                      .read<HistoryBloc>()
                      .add(ToggleFavorite(product, userId));
                },
              ),
            ),
          ],
        );
      },
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
              onEditToggle: () => setState(() => isEditing = !isEditing),
              isFavoriteTab: false,
            ),
            Expanded(
              child: HistoryListView(
                items: state.recentItems,
                isEditing: isEditing,
                onDelete: (product) =>
                    context.read<HistoryBloc>().add(RemoveHistoryItem(product)),
                onToggleFavorite: (product) async {
                  final userId = await _prefs.getCurrentUserId();
                  context
                      .read<HistoryBloc>()
                      .add(ToggleFavorite(product, userId));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
