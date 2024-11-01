import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_navigation_event.dart';
part 'search_navigation_state.dart';

class SearchNavigationBloc
    extends Bloc<SearchNavigationEvent, SearchNavigationState> {
  SearchNavigationBloc() : super(const SearchNavigationInitial()) {
    on<ChangeSearchStatusEvent>((event, emit) {
      emit(SearchNavigationSelected(
          selectedSearchStatus: event.newSearchStatus));
    });
  }
}
