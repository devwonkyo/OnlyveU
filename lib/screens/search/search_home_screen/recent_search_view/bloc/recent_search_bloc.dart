import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'recent_search_event.dart';
part 'recent_search_state.dart';

class RecentSearchBloc extends Bloc<RecentSearchEvent, RecentSearchState> {
  RecentSearchBloc() : super(RecentSearchInitial()) {
    on<AddSearchTerm>(_onAddSearchTerm);
    on<LoadRecentSearches>(_onLoadRecentSearches);
    on<RemoveSearchTerm>(_onRemoveSearchTerm);
  }

  void _onAddSearchTerm(
      AddSearchTerm event, Emitter<RecentSearchState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearches = prefs.getStringList('recentSearches') ?? [];

    recentSearches.remove(event.term);
    recentSearches.insert(0, event.term);
    if (recentSearches.length > 20) {
      recentSearches.removeLast();
    }

    await prefs.setStringList('recentSearches', recentSearches);
    emit(RecentSearchLoaded(recentSearches));
  }

  void _onLoadRecentSearches(
      LoadRecentSearches event, Emitter<RecentSearchState> emit) async {
    emit(RecentSearchLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearches = prefs.getStringList('recentSearches') ?? [];
      await Future.delayed(const Duration(seconds: 2));
      emit(RecentSearchLoaded(recentSearches));
    } catch (e) {
      emit(RecentSearchError(e.toString()));
    }
  }

  void _onRemoveSearchTerm(
      RemoveSearchTerm event, Emitter<RecentSearchState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearches = prefs.getStringList('recentSearches') ?? [];

    recentSearches.remove(event.term);

    await prefs.setStringList('recentSearches', recentSearches);
    emit(RecentSearchLoaded(recentSearches));
  }
}
