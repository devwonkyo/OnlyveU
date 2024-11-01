import 'package:meta/meta.dart';

@immutable
abstract class AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String nickname;
  final String phone;
  final String gender;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.nickname,
    required this.phone,
    required this.gender,
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}
