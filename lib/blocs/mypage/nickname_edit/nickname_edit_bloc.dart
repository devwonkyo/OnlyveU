import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'nickname_edit_event.dart';
import 'nickname_edit_state.dart';

class NicknameEditBloc extends Bloc<NicknameEditEvent, NicknameEditState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  NicknameEditBloc() : super(NicknameEditInitial()) {
    on<LoadCurrentNickname>(_onLoadCurrentNickname);
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
      // Firebase Auth의 사용자 정보 가져오기
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        // Firestore에 닉네임 업데이트
        await _firestore.collection('users').doc(user.email).update({
          'nickname': event.nickname,
        });

        print("닉네임 변경 완료: ${event.nickname}");
        emit(NicknameEditSuccess()); // 닉네임 변경 성공 상태 전환
        emit(NicknameLoaded(event.nickname)); // 변경된 닉네임 바로 로드
      } else {
        emit(const NicknameEditFailure("사용자가 로그인되어 있지 않습니다."));
      }
    } catch (error) {
      emit(const NicknameEditFailure("닉네임 변경에 실패했습니다."));
    }
  }

  Future<void> _onLoadCurrentNickname(
      LoadCurrentNickname event, Emitter<NicknameEditState> emit) async {
    emit(NicknameLoading());
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.email).get();
        String currentNickname = userDoc['nickname'];
        emit(NicknameLoaded(currentNickname));
      } else {
        emit(const NicknameEditFailure("사용자가 로그인되어 있지 않습니다."));
      }
    } catch (e) {
      emit(const NicknameEditFailure("닉네임을 불러오는 데 실패했습니다."));
    }
  }
}
