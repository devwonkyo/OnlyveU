import 'package:meta/meta.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SignUpSuccess extends AuthState {}

class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final String userId;
  LoginSuccess({required this.userId});
}

class LoginFailure extends AuthState {
  final String message;
  LoginFailure(this.message);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class LogoutSuccess extends AuthState {}

class DeleteAccountSuccess extends AuthState {}
