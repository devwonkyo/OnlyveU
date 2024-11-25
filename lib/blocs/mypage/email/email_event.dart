import 'package:equatable/equatable.dart';

abstract class EmailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEmail extends EmailEvent {}
