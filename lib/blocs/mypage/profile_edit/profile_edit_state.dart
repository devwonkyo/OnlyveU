import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileImageLoading extends ProfileState {}

class ProfileImagePicked extends ProfileState {
  final File image;

  ProfileImagePicked(this.image);

  @override
  List<Object?> get props => [image];
}

class ProfileImageUrlLoaded extends ProfileState {
  final String imageUrl;

  ProfileImageUrlLoaded(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
