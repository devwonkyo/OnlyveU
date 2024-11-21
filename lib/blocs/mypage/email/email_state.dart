import 'package:equatable/equatable.dart';

abstract class EmailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmailInitial extends EmailState {}

class EmailLoading extends EmailState {}

class EmailLoaded extends EmailState {
  final String email;

  EmailLoaded(this.email);

  @override
  List<Object?> get props => [email];
}

class EmailError extends EmailState {
  final String message;

  EmailError(this.message);

  @override
  List<Object?> get props => [message];
}
