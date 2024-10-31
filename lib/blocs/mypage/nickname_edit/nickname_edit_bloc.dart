import 'package:flutter_bloc/flutter_bloc.dart';
import 'nickname_edit_event.dart';
import 'nickname_edit_state.dart';

class NicknameEditBloc extends Bloc<NicknameEditEvent, NicknameEditState> {
  NicknameEditBloc() : super(NicknameEditInitial()) {
    on<NicknameChanged>(_onNicknameChanged);
    on<SubmitNicknameChange>(_onSubmitNicknameChange);
  }

  void _onNicknameChanged(
      NicknameChanged event, Emitter<NicknameEditState> emit) {
    final isButtonEnabled = event.nickname.isNotEmpty;
    emit(NicknameEditing(event.nickname, isButtonEnabled: isButtonEnabled));
  }

  Future<void> _onSubmitNicknameChange(
      SubmitNicknameChange event, Emitter<NicknameEditState> emit) async {
    emit(NicknameEditInProgress());
    try {
      emit(NicknameEditSuccess());
    } catch (error) {
      emit(const NicknameEditFailure("닉네임 변경에 실패했습니다."));
    }
  }
}
