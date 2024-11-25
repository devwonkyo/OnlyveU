import 'package:flutter_bloc/flutter_bloc.dart';
import 'set_new_password_event.dart';
import 'set_new_password_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetNewPasswordBloc
    extends Bloc<SetNewPasswordEvent, SetNewPasswordState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _newPassword = ""; // 새 비밀번호
  String _confirmPassword = ""; // 확인 비밀번호

  SetNewPasswordBloc() : super(SetNewPasswordInitial()) {
    on<NewPasswordChanged>(_onNewPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SubmitNewPassword>(_onSubmitNewPassword);
  }

  void _onNewPasswordChanged(
      NewPasswordChanged event, Emitter<SetNewPasswordState> emit) {
    _newPassword = event.newPassword;
    _updateButtonState(emit); // 버튼 활성화 상태 업데이트
  }

  void _onConfirmPasswordChanged(
      ConfirmPasswordChanged event, Emitter<SetNewPasswordState> emit) {
    _confirmPassword = event.confirmPassword;
    _updateButtonState(emit); // 버튼 활성화 상태 업데이트
  }

  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{8,12}$');
    return regex.hasMatch(password);
  }

  void _updateButtonState(Emitter<SetNewPasswordState> emit) {
    final isButtonEnabled = _newPassword.isNotEmpty &&
        _confirmPassword.isNotEmpty &&
        _newPassword == _confirmPassword;
    emit(SetNewPasswordEditing(isButtonEnabled: isButtonEnabled));
  }

  Future<void> _onSubmitNewPassword(
      SubmitNewPassword event, Emitter<SetNewPasswordState> emit) async {
    // 비밀번호가 조건에 맞는지 확인
    if (!_isPasswordValid(_newPassword)) {
      emit(const SetNewPasswordFailure("비밀번호는 8~12자, 영문+숫자를 포함해야 합니다."));
      return;
    } else if (_newPassword != _confirmPassword) {
      emit(const SetNewPasswordFailure("비밀번호가 일치하지 않습니다."));
      return;
    }

    emit(SetNewPasswordInProgress()); // 비밀번호 업데이트 중 상태

    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updatePassword(_newPassword); // Firebase Auth에서 비밀번호 업데이트
        emit(SetNewPasswordSuccess());
      } else {
        emit(const SetNewPasswordFailure("로그인이 필요합니다."));
      }
    } catch (error) {
      emit(SetNewPasswordFailure("비밀번호 변경에 실패했습니다: $error"));
    }
  }
}
