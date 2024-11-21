import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfileImage extends ProfileEvent {}

class PickProfileImage extends ProfileEvent {}

class UploadProfileImage extends ProfileEvent {
  final File image;

  UploadProfileImage(this.image);

  @override
  List<Object?> get props => [image];
}
