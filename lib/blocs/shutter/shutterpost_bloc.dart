// post_bloc.dart
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_event.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_state.dart';
import 'package:onlyveyou/models/post_model.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  PostBloc() : super(PostState()) {
    on<AddImageEvent>((event, emit) async {
      final updatedImages = List<XFile>.from(state.images)..add(event.image);
      emit(state.copyWith(images: updatedImages));

      // Firebase Storage에 이미지 업로드
      String imageUrl = await _uploadImageToStorage(event.image);
      final updatedImageUrls = List<String>.from(state.imageUrls)
        ..add(imageUrl);
      emit(state.copyWith(imageUrls: updatedImageUrls));
    });

    on<RemoveImageEvent>((event, emit) {
      final updatedImages = List<XFile>.from(state.images)
        ..removeAt(event.index);
      final updatedImageUrls = List<String>.from(state.imageUrls)
        ..removeAt(event.index);
      emit(state.copyWith(images: updatedImages, imageUrls: updatedImageUrls));
    });

    on<UpdateTextEvent>((event, emit) {
      emit(state.copyWith(text: event.text));
    });

    on<SubmitPostEvent>((event, emit) async {
      try {
        final postModel = PostModel(
          text: state.text,
          imageUrls: state.imageUrls,
          tags: event.tags,
        );
        await _savePostToFirestore(postModel);
        emit(state.copyWith(postStatus: PostStatus.success));
      } catch (error) {
        emit(state.copyWith(postStatus: PostStatus.failure));
      }
    });
  }

  // Firebase Storage에 이미지를 업로드하고 URL을 반환
  Future<String> _uploadImageToStorage(XFile image) async {
    final ref =
        _storage.ref().child('posts/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(File(image.path));
    return await ref.getDownloadURL();
  }

  // Firestore에 게시물 저장
  Future<void> _savePostToFirestore(PostModel post) async {
    final postRef = _firestore.collection('posts').doc();
    await postRef.set(post.toMap());
  }
}
