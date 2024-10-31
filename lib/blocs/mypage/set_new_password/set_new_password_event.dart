import 'package:equatable/equatable.dart';

abstract class SetNewPasswordEvent extends Equatable {
  const SetNewPasswordEvent();

  @override
  List<Object> get props => [];
}

class NewPasswordChanged extends SetNewPasswordEvent {
  final String newPassword;

  const NewPasswordChanged(this.newPassword);

  @override
  List<Object> get props => [newPassword];
}

class ConfirmPasswordChanged extends SetNewPasswordEvent {
  final String confirmPassword;

  const ConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object> get props => [confirmPassword];
}

class SubmitNewPassword extends SetNewPasswordEvent {}
