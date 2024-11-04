import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_text_field_event.dart';
part 'search_text_field_state.dart';

class SearchTextFieldBloc
    extends Bloc<SearchTextFieldEvent, SearchTextFieldState> {
  SearchTextFieldBloc() : super(Empty()) {
    on<TextChanged>((event, emit) {
      if (event.text.isEmpty) {
        emit(Empty());
      } else {
        emit(Typing());
      }
    });

    on<TextSubmitted>((event, emit) {
      if (event.text.isNotEmpty) {
        emit(Submitted());
      }
    });

    on<TextDelete>((event, emit) {
      emit(Empty());
    });
  }
}



// void _onTextChanged() {
//     if (_state != SearchTextFieldState.typing && _controller.text.isNotEmpty) {
//       return setState(() {
//         _state = SearchTextFieldState.typing;
//       });
//     } else if (_state == SearchTextFieldState.submitted &&
//         _controller.text.isEmpty) {
//       return setState(() {
//         _state = SearchTextFieldState.empty;
//       });
//     }
//   }