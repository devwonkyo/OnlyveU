import 'package:flutter_bloc/flutter_bloc.dart';
import 'password_event.dart';
import 'password_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _currentPassword = ''; // 현재 비밀번호를 저장
  PasswordBloc() : super(PasswordInitial()) {
    on<PasswordChanged>(_onPasswordChanged);
    on<SubmitPasswordChange>(_onSubmitPasswordChange);
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<PasswordState> emit) {
    // 비밀번호가 비어있지 않으면 버튼을 활성화
    _currentPassword = event.password;
    final isButtonEnabled = event.password.isNotEmpty;
    emit(PasswordEditing(isButtonEnabled: isButtonEnabled));
  }

  Future<void> _onSubmitPasswordChange(
      SubmitPasswordChange event, Emitter<PasswordState> emit) async {
    print("SubmitPasswordChange 이벤트 호출됨");
    emit(PasswordVerificationInProgress());

    try {
      // Firebase Auth의 현재 사용자 가져오기
      User? user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const PasswordVerificationFailure("로그인이 필요합니다."));
        return;
      }

      // 저장된 비밀번호를 사용하여 재인증
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 비밀번호 일치 -> 다음 화면으로 이동
      emit(PasswordEditSuccess());
      print("PasswordEditSuccess 상태로 전환됨");
    } catch (error) {
      print("비밀번호 확인 실패: $error");
      emit(const PasswordVerificationFailure("현재 비밀번호가 틀렸습니다."));
    }
  }
}
