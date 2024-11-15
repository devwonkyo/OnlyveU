import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../../models/search_models/search_models.dart';
import '../../../../../repositories/search_repositories/suggestion_repository/suggestion_repository.dart';

part 'trend_search_event.dart';
part 'trend_search_state.dart';

class TrendSearchBloc extends Bloc<TrendSearchEvent, TrendSearchState> {
  final SuggestionRepository repository;
  TrendSearchBloc({required this.repository}) : super(TrendSearchInitial()) {
    on<LoadTrendSearch>(_onLoadTrendSearch);

    add(LoadTrendSearch());
  }

  Future<void> _onLoadTrendSearch(
    LoadTrendSearch event,
    Emitter<TrendSearchState> emit,
  ) async {
    emit(TrendSearchLoading());
    try {
      final trendSearches = await repository.getTrendSearches();
      final now = DateTime.now();
      await Future.delayed(const Duration(seconds: 1));
      emit(TrendSearchLoaded(trendSearches,
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'));
      debugPrint('급상승 검색어 업데이트');
    } catch (e) {
      emit(TrendSearchError(e.toString()));
    }
  }
}
