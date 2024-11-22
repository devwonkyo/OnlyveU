import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../repositories/search_repositories/recent_search_repository/recent_search_repository.dart';

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

  @override
  Future<void> close() {
    debugPrint('RecentSearchBloc disposed');
    return super.close();
  }

  void _onAddSearchTerm(
      AddSearchTerm event, Emitter<RecentSearchState> emit) async {
    await repository.addSearchTerm(event.term);
    final recentSearches = await repository.loadRecentSearches();
    emit(RecentSearchLoaded(recentSearches));
  }

  void _onLoadRecentSearches(
      LoadRecentSearches event, Emitter<RecentSearchState> emit) async {
    // 로딩화면 디버그용 (지워도됨)
    if (state is RecentSearchInitial) {
      emit(RecentSearchLoading());
      await Future.delayed(const Duration(milliseconds: 1200));
    }
    emit(RecentSearchLoading());
    try {
      final recentSearches = await repository.loadRecentSearches();
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
    try {
      await repository.removeSearchTerm(event.term);
      final recentSearches = await repository.loadRecentSearches();
      emit(RecentSearchLoading());
      emit(RecentSearchLoaded(recentSearches));
    } catch (e) {
      emit(RecentSearchError(e.toString()));
    }
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
