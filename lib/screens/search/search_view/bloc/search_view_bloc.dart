import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/screens/search/search_text_field/search_text_field.dart';

part 'search_view_event.dart';
part 'search_view_state.dart';

class SearchViewBloc extends Bloc<SearchViewEvent, SearchViewState> {
  SearchViewBloc() : super(Home()) {
    on<ChangeView>((event, emit) {
      switch (event.newStatus) {
        case SearchTextFieldStatus.empty:
          emit(Home());
          break;
        case SearchTextFieldStatus.typing:
          emit(Suggestion());
          break;
        case SearchTextFieldStatus.submitted:
          emit(Result());
          break;
        default:
      }

      // if (state == SearchTextFieldStatus.empty) {
      //   emit(Home());
      // }else if(state == SearchTextFieldStatus.typing) {
      //   emit(Suggestion());
      // }else if(state == SearchTextFieldStatus.empty) {
      //   emit(Home());
      // }else if
    });
  }
}
