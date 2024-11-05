import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_suggestion_event.dart';
part 'search_suggestion_state.dart';

class SearchSuggestionBloc
    extends Bloc<SearchSuggestionEvent, SearchSuggestionState> {
  SearchSuggestionBloc() : super(SearchSuggestionInitial()) {
    on<FetchSearchSuggestions>(_onFetchSearchSuggestions);
  }

  Future<void> _onFetchSearchSuggestions(
    FetchSearchSuggestions event,
    Emitter<SearchSuggestionState> emit,
  ) async {
    emit(SearchSuggestionLoading());
    try {
      // 여기에 실제 API 호출 또는 데이터베이스 조회 로직을 추가합니다.
      // 예시로 간단한 딜레이와 하드코딩된 데이터를 사용합니다.
      await Future.delayed(Duration(seconds: 1));
      final suggestions = List<String>.generate(
          5, (index) => '${event.query} suggestion $index');
      emit(SearchSuggestionLoaded(suggestions));
    } catch (e) {
      emit(SearchSuggestionError('Failed to fetch suggestions'));
    }
  }
}
