import 'package:flutter_bloc/flutter_bloc.dart';
import 'set_new_password_event.dart';
import 'set_new_password_state.dart';

class SetNewPasswordBloc
    extends Bloc<SetNewPasswordEvent, SetNewPasswordState> {
  String _newPassword = ""; // 비밀번호 값을 업데이트할 수 있도록 변경
  String _confirmPassword = "";

  SetNewPasswordBloc() : super(SetNewPasswordInitial()) {
    on<NewPasswordChanged>(_onNewPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SubmitNewPassword>(_onSubmitNewPassword);
  }

  void _onNewPasswordChanged(
      NewPasswordChanged event, Emitter<SetNewPasswordState> emit) {
    _newPassword = event.newPassword; // 새 비밀번호 업데이트
    _updateButtonState(emit); // 버튼 활성화 여부 업데이트
  }

  void _onConfirmPasswordChanged(
      ConfirmPasswordChanged event, Emitter<SetNewPasswordState> emit) {
    _confirmPassword = event.confirmPassword; // 확인 비밀번호 업데이트
    _updateButtonState(emit); // 버튼 활성화 여부 업데이트
  }

  void _updateButtonState(Emitter<SetNewPasswordState> emit) {
    final isButtonEnabled = _newPassword.isNotEmpty &&
        _confirmPassword.isNotEmpty &&
        _newPassword == _confirmPassword;
    emit(SetNewPasswordEditing(isButtonEnabled: isButtonEnabled));
  }

  Future<void> _onSubmitNewPassword(
      SubmitNewPassword event, Emitter<SetNewPasswordState> emit) async {
    if (_newPassword == _confirmPassword && _newPassword.isNotEmpty) {
      emit(SetNewPasswordSuccess());
    } else {
      emit(const SetNewPasswordFailure("비밀번호가 일치하지 않습니다."));
    }
  }
}
