import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlyveyou/models/user_model.dart';
import 'package:onlyveyou/repositories/auth_repository.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final OnlyYouSharedPreference sharedPreference;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _prefs = OnlyYouSharedPreference();

  //authrepository 메서드 가져오기 위해서 사용
  AuthBloc({required this.authRepository, required this.sharedPreference})
      : super(AuthInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<GetUserInfo>(_getUserCartCount);
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      print('emit AuthLoading');
      try {
        // 회원가입 및 이메일 인증 전송
        UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        await userCredential.user?.sendEmailVerification();

        // 얻은 ID로 UserModel 생성
        final userModel = UserModel(
          uid: userCredential.user!.uid,  // Firestore가 생성한 ID를 uid로 사용
          email: event.email,
          nickname: event.nickname,
          phone: event.phone,
          gender: event.gender
        );

        // 3. Authentication의 UID로 Firestore 문서 저장
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)  // Authentication의 UID 사용
            .set(userModel.toMap());

        // // SharedPreferences에 사용자 정보 저장
        // await _prefs.setUserId(userCredential.user!.uid);
        // await _prefs.setEmail(event.email);
        // await _prefs.setNickname(event.nickname);
        // await _prefs.setPhone(event.phone);
        // await _prefs.setGender(event.gender);

        emit(SignUpSuccess());
        print('emit SignUpSuccess');
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? '회원가입에 실패했습니다.'));
        print('emit AuthFailure $e');
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(LoginLoading());
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
          emit(LoginFailure('이메일 인증을 완료해주세요.'));
          await _firebaseAuth.signOut();
        }
      } catch (e) {
        emit(LoginFailure('로그인에 실패했습니다.'));
      }
    });
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // 로그아웃 중 로딩 상태로 변경
    try {
      await sharedPreference.printAllData();
      await authRepository.logout(); // 로그아웃 수행

      await sharedPreference.clearPreference();
      await sharedPreference.printAllData();
      emit(LogoutSuccess()); // 로그아웃 성공 상태로 전환
    } catch (e) {
      emit(AuthFailure("로그아웃에 실패했습니다: $e"));
    }
  }

  // 회원 탈퇴 로직
  Future<void> _onDeleteAccountRequested(
      DeleteAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // 현재 사용자 ID 가져오기
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        emit(AuthFailure("사용자가 인증되지 않았습니다."));
        return;
      }

      // Firestore에서 유저 데이터 삭제
      await _firestore.collection('users').doc(currentUser.email).delete();

      // 내부 저장소의 사용자 데이터 삭제
      await sharedPreference.clearPreference();

      // Firebase Auth에서 계정 삭제
      await authRepository.deleteAccount();

      emit(LogoutSuccess()); // 탈퇴 후 로그인 화면으로 이동
    } catch (e) {
      emit(AuthFailure("회원 탈퇴에 실패했습니다: $e"));
    }
  }

  Future<void> _getUserCartCount(GetUserInfo event, Emitter<AuthState> emit) async {
    int userCartCount = await authRepository.getCartItemsCount();
    print("userCartCount : $userCartCount");
    emit(LoadedUserCartCount(cartItemsCount: userCartCount));
  }
}
