import 'package:flutter_bloc/flutter_bloc.dart';
import 'password_event.dart';
import 'password_state.dart';

class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  PasswordBloc() : super(PasswordInitial()) {
    on<PasswordChanged>(_onPasswordChanged);
    on<SubmitPasswordChange>(_onSubmitPasswordChange);
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<PasswordState> emit) {
    // 비밀번호가 비어있지 않으면 버튼을 활성화
    final isButtonEnabled = event.password.isNotEmpty;
    emit(PasswordEditing(isButtonEnabled: isButtonEnabled));
  }

  void _onSubmitPasswordChange(
      SubmitPasswordChange event, Emitter<PasswordState> emit) async {
    print("SubmitPasswordChange 이벤트 호출됨");
    emit(PasswordVerificationInProgress());

    emit(PasswordEditSuccess());
    print("PasswordEditSuccess 상태로 전환됨");
  }
}
