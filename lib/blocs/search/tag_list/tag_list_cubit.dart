import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/tag_model.dart';

part 'tag_list_state.dart';

class TagListCubit extends Cubit<TagListState> {
  TagListCubit() : super(TagListState.initial());
}
