import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_event.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_state.dart';
import 'package:onlyveyou/models/post_model.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  PostBloc() : super(PostState.initial()) {
    on<AddImageEvent>((event, emit) {
      final updatedImages = List<XFile>.from(state.images)..add(event.image);
      emit(state.copyWith(images: updatedImages));
    });

    on<UpdateTextEvent>((event, emit) {
      emit(state.copyWith(text: event.text));
    });

    on<SubmitPostEvent>((event, emit) async {
      try {
        // 이미지 업로드 및 URL 수집
        final imageUrls = await Future.wait(event.images.map((imageFile) async {
          final ref = _firebaseStorage
              .ref()
              .child('post_images/${DateTime.now().millisecondsSinceEpoch}');
          final uploadTask = await ref.putFile(File(imageFile.path));
          return await uploadTask.ref.getDownloadURL();
        }));

        // Firestore에 저장할 데이터 생성
        final post = PostModel(
          text: event.text,
          imageUrls: imageUrls,
          tags: event.tags,
        );

        // Firestore에 데이터 저장
        await _firestore.collection('posts').add(post.toMap());

        // 저장 성공 후 초기화
        emit(state.copyWith(text: '', images: []));
      } catch (e) {
        print('Error saving post: $e');
      }
    });
  }
}
