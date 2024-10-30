import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProfileEditState extends Equatable {
  @override
  List<Object?> get props => [];
}

//초기 상태, 아무 이미지 선택 안된 상태
class ProfileEditInitial extends ProfileEditState {}

//사용자가 이미지 선택했을 때 상태
class ProfileImagePicked extends ProfileEditState {
  final File image;

  ProfileImagePicked(this.image);

  @override
  List<Object?> get props => [image];
}

//이미지 저장 상태
class ProfileImageSaved extends ProfileEditState {}

//오류 발생 상태
class ProfileEditError extends ProfileEditState {
  final String message;

  ProfileEditError(this.message);

  @override
  List<Object?> get props => [message];
}
