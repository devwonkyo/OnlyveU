import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _prefs = OnlyYouSharedPreference();

  AuthBloc() : super(AuthInitial()) {
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // 회원가입 및 이메일 인증 전송
        UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        await userCredential.user?.sendEmailVerification();

        // Firestore에 사용자 저장
        await _firestore.collection('users').doc(event.email).set({
          'email': event.email,
          'nickname': event.nickname,
          'phone': event.phone,
          'gender': event.gender,
        });
        // SharedPreferences에 사용자 정보 저장
        await _prefs.setUserId(userCredential.user!.uid);
        await _prefs.setEmail(event.email);
        await _prefs.setNickname(event.nickname);
        await _prefs.setPhone(event.phone);
        await _prefs.setGender(event.gender);

        emit(SignUpSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? '회원가입에 실패했습니다.'));
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential =
            await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        if (userCredential.user?.emailVerified ?? false) {
          // SharedPreferences에 userId 저장
          await _prefs.setUserId(userCredential.user!.uid);

          // 다른 사용자 정보도 저장
          await _prefs.setEmail(event.email);
          // ... 다른 정보들 저장

          emit(LoginSuccess(userId: userCredential.user!.uid));
        } else {
          emit(AuthFailure('이메일 인증을 완료해주세요.'));
          await _firebaseAuth.signOut();
        }
      } catch (e) {
        emit(AuthFailure('로그인에 실패했습니다.'));
      }
    });
  }
}
