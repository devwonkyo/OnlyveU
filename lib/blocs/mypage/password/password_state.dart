import 'package:equatable/equatable.dart';

abstract class PasswordState extends Equatable {
  const PasswordState();

  @override
  List<Object?> get props => [];
}

class PasswordInitial extends PasswordState {}

class PasswordEditing extends PasswordState {
  final bool isButtonEnabled;

  const PasswordEditing({required this.isButtonEnabled});

  @override
  List<Object?> get props => [isButtonEnabled];
}

class PasswordVerificationInProgress extends PasswordState {}

class PasswordVerificationSuccess extends PasswordState {}

class PasswordEditSuccess extends PasswordState {}

class PasswordVerificationFailure extends PasswordState {
  final String errorMessage;

  const PasswordVerificationFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
