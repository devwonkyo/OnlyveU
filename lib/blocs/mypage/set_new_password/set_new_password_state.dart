import 'package:equatable/equatable.dart';

abstract class SetNewPasswordState extends Equatable {
  const SetNewPasswordState();

  @override
  List<Object?> get props => [];
}

class SetNewPasswordInitial extends SetNewPasswordState {}

class SetNewPasswordEditing extends SetNewPasswordState {
  final bool isButtonEnabled;

  const SetNewPasswordEditing({required this.isButtonEnabled});

  @override
  List<Object?> get props => [isButtonEnabled];
}

class SetNewPasswordInProgress extends SetNewPasswordState {} // 비밀번호 업데이트 중 상태

class SetNewPasswordSuccess extends SetNewPasswordState {}

class SetNewPasswordFailure extends SetNewPasswordState {
  final String error;

  const SetNewPasswordFailure(this.error);

  @override
  List<Object?> get props => [error];
}
