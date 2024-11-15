// shutterpost_bloc.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlyveyou/models/post_model.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_event.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  PostBloc() : super(PostState.initial()) {
    on<AddImageEvent>((event, emit) {
      final updatedImages = List<XFile>.from(state.images)..add(event.image);
      emit(state.copyWith(images: updatedImages));
    });

    on<UpdateTextEvent>((event, emit) {
      emit(state.copyWith(text: event.text));
    });

    on<SubmitPostEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        if (state.images.isEmpty) return;

        // Get current user's UID
        final User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final String uid = user?.uid ?? ''; // 로그인된 사용자의 uid
          print('Logged in as: $uid'); // 콘솔에 uid 출력
        } else {
          print('No user logged in');
        }
        final authorUid = user?.uid ?? ''; // Ensure you get the UID correctly

        // Upload images to Firebase Storage
        final imageUrls = await Future.wait(state.images.map((image) async {
          final file = File(image.path);
          final fileName =
              'post_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
          final ref = _storage.ref().child(fileName);
          await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
          return await ref.getDownloadURL();
        }));

        // Save post to Firestore
        final post = PostModel(
          text: state.text,
          imageUrls: imageUrls,
          tags: event.tags,
          createdAt: DateTime.now(),
          authorUid: user?.uid ?? '', // Use the actual UID
        );
        await _firestore.collection('posts').add(post.toMap());

        emit(PostState.initial());
      } catch (e) {
        print('Error: $e');
      }
      emit(state.copyWith(isLoading: false));
    });
  }
}
