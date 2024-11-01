import 'package:equatable/equatable.dart';

abstract class PhoneNumberEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPhoneNumber extends PhoneNumberEvent {}

class PhoneNumberChanged extends PhoneNumberEvent {
  final String phoneNumber;

  PhoneNumberChanged(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class SubmitPhoneNumberChange extends PhoneNumberEvent {
  final String phoneNumber;

  SubmitPhoneNumberChange(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}
