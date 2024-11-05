import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_text_field_event.dart';
part 'search_text_field_state.dart';

class SearchTextFieldBloc
    extends Bloc<SearchTextFieldEvent, SearchTextFieldState> {
  SearchTextFieldBloc() : super(SearchTextFieldEmpty()) {
    on<TextChanged>((event, emit) {
      if (event.text.isEmpty) {
        return emit(SearchTextFieldEmpty());
      } else {
        print('STFBloc: ${event.text}');
        return emit(SearchTextFieldTyping(event.text));
      }
    });

    on<TextSubmitted>((event, emit) {
      return emit(SearchTextFieldSubmitted());
    });

    on<TextDeleted>((event, emit) {
      return emit(SearchTextFieldEmpty());
    });
  }
}
