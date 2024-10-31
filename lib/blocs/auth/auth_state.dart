import 'package:meta/meta.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SignUpSuccess extends AuthState {}

class LoginSuccess extends AuthState {
  final String userId;
  LoginSuccess({required this.userId});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
