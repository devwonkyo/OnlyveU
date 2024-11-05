// import 'package:equatable/equatable.dart';
// import 'dart:io';

// abstract class ProfileEditState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// //초기 상태, 아무 이미지 선택 안된 상태
// class ProfileEditInitial extends ProfileEditState {}

// //사용자가 이미지 선택했을 때 상태
// class ProfileImagePicked extends ProfileEditState {
//   final File image;

//   ProfileImagePicked(this.image);

//   @override
//   List<Object?> get props => [image];
// }

// //이미지 저장 상태
// class ProfileImageSaved extends ProfileEditState {}

// //오류 발생 상태
// class ProfileEditError extends ProfileEditState {
//   final String message;

//   ProfileEditError(this.message);

//   @override
//   List<Object?> get props => [message];
// }

// // 이메일 로딩 중 상태
// class EmailLoading extends ProfileEditState {}

// // 이메일 로드 성공 상태
// class EmailLoaded extends ProfileEditState {
//   final String email;

//   EmailLoaded(this.email);

//   @override
//   List<Object?> get props => [email];
// }
import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProfileEditState extends Equatable {
  @override
  List<Object?> get props => [];
}

// 초기 상태, 아무 이미지 선택 안된 상태
class ProfileEditInitial extends ProfileEditState {}

// 사용자가 이미지 선택했을 때 상태
class ProfileImagePicked extends ProfileEditState {
  final File image;

  ProfileImagePicked(this.image);

  @override
  List<Object?> get props => [image];
}

// 이미지 업로드 진행 중 상태
class ProfileImageUploadInProgress extends ProfileEditState {}

// 이미지 업로드 성공 상태 (이미지 URL 로드)
class ProfileImageUrlLoaded extends ProfileEditState {
  final String imageUrl;

  ProfileImageUrlLoaded(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

// 이미지 저장 상태
class ProfileImageSaved extends ProfileEditState {}

// 오류 발생 상태
class ProfileEditError extends ProfileEditState {
  final String message;

  ProfileEditError(this.message);

  @override
  List<Object?> get props => [message];
}

// 이메일 로딩 중 상태
class EmailLoading extends ProfileEditState {}

// 이메일 로드 성공 상태
class EmailLoaded extends ProfileEditState {
  final String email;

  EmailLoaded(this.email);

  @override
  List<Object?> get props => [email];
}
