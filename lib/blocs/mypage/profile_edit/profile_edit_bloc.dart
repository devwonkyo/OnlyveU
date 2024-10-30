import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_edit_event.dart';
import 'profile_edit_state.dart';

class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  final ImagePicker _picker = ImagePicker();

  ProfileEditBloc() : super(ProfileEditInitial()) {
    on<PickProfileImage>(_onPickProfileImage);
    on<SaveProfileImage>(_onSaveProfileImage);
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
