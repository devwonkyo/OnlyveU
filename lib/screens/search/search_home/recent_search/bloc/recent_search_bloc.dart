import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../../repositories/search_repositories/recent_search_repository/recent_search_repository.dart';

part 'recent_search_event.dart';
part 'recent_search_state.dart';

class RecentSearchBloc extends Bloc<RecentSearchEvent, RecentSearchState> {
  final RecentSearchRepository repository;
  RecentSearchBloc({required this.repository}) : super(RecentSearchInitial()) {
    on<AddSearchTerm>(_onAddSearchTerm);
    on<LoadRecentSearches>(_onLoadRecentSearches);
    on<RemoveSearchTerm>(_onRemoveSearchTerm);
    on<ClearAllSearchTerms>(_onClearAllSearchTerms);

    add(LoadRecentSearches());
  }

  void _onAddSearchTerm(
      AddSearchTerm event, Emitter<RecentSearchState> emit) async {
    await repository.addSearchTerm(event.term);
    final recentSearches = await repository.loadRecentSearches();
    emit(RecentSearchLoaded(recentSearches));
  }

  void _onLoadRecentSearches(
      LoadRecentSearches event, Emitter<RecentSearchState> emit) async {
    emit(RecentSearchLoading());
    try {
      final recentSearches = await repository.loadRecentSearches();
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('onLoadRecentSearch: $recentSearches');
      if (recentSearches.isEmpty) {
        emit(RecentSearchEmpty());
      } else {
        emit(RecentSearchLoaded(recentSearches));
      }
    } catch (e) {
      emit(RecentSearchError(e.toString()));
    }
  }

  void _onRemoveSearchTerm(
      RemoveSearchTerm event, Emitter<RecentSearchState> emit) async {
    await repository.removeSearchTerm(event.term);
    final recentSearches = await repository.loadRecentSearches();
    emit(RecentSearchLoaded(recentSearches));
  }

  void _onClearAllSearchTerms(
      ClearAllSearchTerms event, Emitter<RecentSearchState> emit) async {
    try {
      await repository.clearAllSearchTerms();
      emit(RecentSearchEmpty());
    } catch (e) {
      emit(RecentSearchError(e.toString()));
    }
  }
}
