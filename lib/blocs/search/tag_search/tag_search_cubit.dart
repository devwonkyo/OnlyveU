import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'tag_search_state.dart';

class TagSearchCubit extends Cubit<TagSearchState> {
  final Debounce _debounce = Debounce(milliseconds: 500);
  TagSearchCubit() : super(TagSearchState.initial());

  void setSearchTerm(String newSearchTerm) {
    _debounce.run(() {
      emit(state.copyWith(searchTerm: newSearchTerm));
    });
  }
}

class Debounce {
  final int milliseconds;
  Debounce({
    required this.milliseconds,
  });

  Timer? _timer;

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
