import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_state.dart';
import 'package:onlyveyou/repositories/mypage/profile_image_repository.dart';

import 'dart:io';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileImageRepository _repository;

  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<LoadProfileImage>(_onLoadProfileImage);
    on<PickProfileImage>(_onPickProfileImage);
    on<UploadProfileImage>(_onUploadProfileImage);
  }

  Future<void> _onLoadProfileImage(
      LoadProfileImage event, Emitter<ProfileState> emit) async {
    emit(ProfileImageLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in.");

      final imageUrl = await _repository.getProfileImageUrl(user.uid);
      if (imageUrl != null) {
        emit(ProfileImageUrlLoaded(imageUrl));
      } else {
        emit(ProfileInitial());
      }
    } catch (e) {
      emit(ProfileError("Failed to load profile image: $e"));
    }
  }

  Future<void> _onPickProfileImage(
      PickProfileImage event, Emitter<ProfileState> emit) async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        emit(ProfileImagePicked(File(pickedFile.path)));
        add(UploadProfileImage(File(pickedFile.path)));
      }
    } catch (e) {
      emit(ProfileError("Failed to pick image: $e"));
    }
  }

  Future<void> _onUploadProfileImage(
      UploadProfileImage event, Emitter<ProfileState> emit) async {
    emit(ProfileImageLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in.");

      final imageUrl =
          await _repository.uploadProfileImage(user.uid, event.image);
      await _repository.saveProfileImageUrl(user.uid, imageUrl);

      emit(ProfileImageUrlLoaded(imageUrl));
    } catch (e) {
      emit(ProfileError("Failed to upload profile image: $e"));
    }
  }
}
