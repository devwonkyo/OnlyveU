import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_edit_event.dart';
import 'profile_edit_state.dart';

class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth 인스턴스 추가
  ProfileEditBloc() : super(ProfileEditInitial()) {
    on<PickProfileImage>(_onPickProfileImage);
    on<SaveProfileImage>(_onSaveProfileImage);
    on<LoadEmail>(_onLoadEmail); // LoadEmail 이벤트 핸들러 추가
  }

  Future<void> _onLoadEmail(
      LoadEmail event, Emitter<ProfileEditState> emit) async {
    emit(EmailLoading());
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // 1. 먼저 현재 인증된 사용자의 이메일을 시도
        if (currentUser.email != null) {
          emit(EmailLoaded(currentUser.email!));
          return;
        }

        // 2. Firestore에서 추가 확인
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid) // uid를 사용하여 문서 참조
            .get();

        if (userDoc.exists && userDoc.data()?['email'] != null) {
          final email = userDoc.data()!['email'] as String;
          emit(EmailLoaded(email));
        } else {
          emit(ProfileEditError("이메일을 찾을 수 없습니다."));
        }
      } else {
        emit(ProfileEditError("로그인이 필요합니다."));
      }
    } catch (e) {
      print("이메일 로드 에러: $e");
      emit(ProfileEditError("이메일을 불러오는데 실패했습니다."));
    }
  }

  Future<void> _onPickProfileImage(
      PickProfileImage event, Emitter<ProfileEditState> emit) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // 새로운 이미지를 선택한 경우, 상태를 ProfileImagePicked로 업데이트
        emit(ProfileImagePicked(File(pickedFile.path)));
        print("이미지 선택 성공");
      } else {
        // 이미 선택된 이미지가 있다면 해당 상태를 유지, 아니면 초기 상태 유지
        if (state is ProfileImagePicked) {
          emit(state); // 현재 상태 유지
        } else {
          emit(ProfileEditInitial()); // 기본 상태로 유지
        }
        print("이미지 선택 취소");
      }
    } catch (e) {
      emit(ProfileEditError("Failed to pick image"));
      print("Failed to pick image: $e");
    }
  }

  Future<void> _onSaveProfileImage(
      SaveProfileImage event, Emitter<ProfileEditState> emit) async {
    try {
      // 프로필 사진을 서버에 저장하는 로직 구현
      // 예시로는 간단하게 성공 상태로 전환합니다.
      emit(ProfileImageSaved());
      print("이미지 저장 성공");
    } catch (e) {
      emit(ProfileEditError("Failed to save image"));
      print("Failed to save image: $e");
    }
  }
}
