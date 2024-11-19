import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlyveyou/models/post_model.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_event.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_state.dart';
import 'package:onlyveyou/screens/shutter/firestore_service.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirestoreService _firestoreService = FirestoreService();

  PostBloc() : super(PostState.initial()) {
    on<AddImageEvent>((event, emit) {
      final updatedImages = List<XFile>.from(state.images)..add(event.image);
      emit(state.copyWith(images: updatedImages));
    });

    on<UpdateTextEvent>((event, emit) {
      emit(state.copyWith(text: event.text));
    });

    on<ToggleLikeEvent>((event, emit) async {
      try {
        await _firestoreService.toggleLike(event.postId, event.userId);
      } catch (e) {
        print('Error in ToggleLikeEvent: $e');
        emit(state.copyWith(error: e.toString()));
      }
    });

    on<SubmitPostEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        if (state.images.isEmpty) return;

        final User? user = FirebaseAuth.instance.currentUser;
        final authorUid = user?.uid ?? '';
        if (authorUid.isEmpty) throw Exception('User not logged in.');

        // 사용자 프로필 정보 가져오기
        final userDoc =
            await _firestore.collection('users').doc(authorUid).get();
        final userData = userDoc.data();
        final nickname = userData?['nickname'] ?? 'Unknown';
        final profileImageUrl = userData?['profileImageUrl'] ?? '';

        // 이미지 업로드
        final imageUrls = await Future.wait(state.images.map((image) async {
          final file = File(image.path);
          final fileName =
              'post_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
          final ref = _storage.ref().child(fileName);
          await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
          return await ref.getDownloadURL();
        }));

        // 게시물 생성
        final docRef = _firestore.collection('posts').doc();
        final post = PostModel(
          id: docRef.id,
          text: state.text,
          imageUrls: imageUrls,
          tags: event.tags,
          createdAt: DateTime.now(),
          authorUid: authorUid,
          authorName: nickname,
          authorProfileImageUrl: profileImageUrl,
          likes: 0,
          likedBy: [],
        );

        await docRef.set(post.toMap());
        emit(PostState.initial());
      } catch (e) {
        print('Error: $e');
        emit(state.copyWith(error: e.toString()));
      }
      emit(state.copyWith(isLoading: false));
    });
  }
}
