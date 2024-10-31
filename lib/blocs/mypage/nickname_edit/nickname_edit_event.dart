import 'package:equatable/equatable.dart';

abstract class NicknameEditEvent extends Equatable {
  const NicknameEditEvent();

  @override
  List<Object?> get props => [];
}

// 닉네임이 입력될 때 발생하는 이벤트
class NicknameChanged extends NicknameEditEvent {
  final String nickname;

  const NicknameChanged(this.nickname);

  @override
  List<Object?> get props => [nickname];
}

// 닉네임 변경 버튼을 클릭했을 때 발생하는 이벤트
class SubmitNicknameChange extends NicknameEditEvent {}
