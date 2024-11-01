import 'package:equatable/equatable.dart';

abstract class PhoneNumberState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PhoneNumberInitial extends PhoneNumberState {}

class PhoneNumberLoading extends PhoneNumberState {}

class PhoneNumberLoaded extends PhoneNumberState {
  final String phoneNumber;

  PhoneNumberLoaded(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class PhoneNumberEditing extends PhoneNumberState {
  final String phoneNumber;
  final bool isButtonEnabled;

  PhoneNumberEditing(
      {required this.phoneNumber, required this.isButtonEnabled});

  @override
  List<Object?> get props => [phoneNumber, isButtonEnabled];
}

class PhoneNumberError extends PhoneNumberState {
  final String message;

  PhoneNumberError(this.message);

  @override
  List<Object?> get props => [message];
}
