import 'package:equatable/equatable.dart';

abstract class NicknameEditState extends Equatable {
  const NicknameEditState();

  @override
  List<Object?> get props => [];
}

// 초기 상태
class NicknameEditInitial extends NicknameEditState {}

// 닉네임이 입력된 상태
class NicknameEditing extends NicknameEditState {
  final String nickname;
  final bool isButtonEnabled;

  const NicknameEditing(this.nickname, {required this.isButtonEnabled});

  @override
  List<Object?> get props => [nickname, isButtonEnabled];
}

// 닉네임 변경 요청 중 상태
class NicknameEditInProgress extends NicknameEditState {}

// 닉네임 변경 성공 상태
class NicknameEditSuccess extends NicknameEditState {}

// 닉네임 변경 실패 상태
class NicknameEditFailure extends NicknameEditState {
  final String errorMessage;

  const NicknameEditFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

//닉네임 가져오기 State
class NicknameLoading extends NicknameEditState {}

class NicknameLoaded extends NicknameEditState {
  final String nickname;

  const NicknameLoaded(this.nickname);

  @override
  List<Object?> get props => [nickname];
}
