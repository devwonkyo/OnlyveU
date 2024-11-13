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
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        // uid를 document ID로 사용
        await _firestore.collection('users').doc(user.uid).update({
          'nickname': event.nickname,
        });

        print("닉네임 변경 완료: ${event.nickname}");
        emit(NicknameEditSuccess());
        emit(NicknameLoaded(event.nickname));
      } else {
        emit(const NicknameEditFailure("사용자가 로그인되어 있지 않습니다."));
      }
    } catch (error) {
      print("닉네임 변경 실패: $error"); // 디버깅용 로그 추가
      emit(const NicknameEditFailure("닉네임 변경에 실패했습니다."));
    }
  }

  Future<void> _onLoadCurrentNickname(
      LoadCurrentNickname event, Emitter<NicknameEditState> emit) async {
    emit(NicknameLoading());
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        // email을 document ID로 사용하는 대신 user.uid를 사용
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String currentNickname = userDoc.get('nickname') ?? '';
          print("Loaded nickname: $currentNickname"); // 디버깅용 로그
          emit(NicknameLoaded(currentNickname));
        } else {
          print("User document does not exist"); // 디버깅용 로그
          emit(const NicknameEditFailure("사용자 정보를 찾을 수 없습니다."));
        }
      } else {
        print("No user logged in"); // 디버깅용 로그
        emit(const NicknameEditFailure("사용자가 로그인되어 있지 않습니다."));
      }
    } catch (e) {
      print("Error loading nickname: $e"); // 디버깅용 로그
      emit(const NicknameEditFailure("닉네임을 불러오는 데 실패했습니다."));
    }
  }
}
