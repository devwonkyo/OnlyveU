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
  final FirebaseStorage _storage = FirebaseStorage.instance;

  PostBloc() : super(PostState.initial()) {
    on<AddImageEvent>((event, emit) {
      final updatedImages = List<XFile>.from(state.images)..add(event.image);
      print('Adding image: ${event.image.path}');
      print('Current images count: ${updatedImages.length}');
      emit(state.copyWith(images: updatedImages));
    });

    on<UpdateTextEvent>((event, emit) {
      emit(state.copyWith(text: event.text));
    });

    on<SubmitPostEvent>((event, emit) async {
      try {
        // Use state.images instead of event.images
        if (state.images.isEmpty) {
          print('No images in state');
          return;
        }

        print('Starting to upload ${state.images.length} images');
        List<String> imageUrls = [];

        // Upload images to Firebase Storage
        for (XFile imageFile in state.images) {
          print('Processing image: ${imageFile.path}');
          File file = File(imageFile.path);

          if (!await file.exists()) {
            print('File does not exist: ${imageFile.path}');
            continue;
          }

          // Generate unique filename
          String fileName =
              'post_images/${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.jpg';
          Reference storageRef = _storage.ref().child(fileName);

          print('Uploading to Firebase Storage: $fileName');

          // Upload file
          try {
            await storageRef.putFile(
              file,
              SettableMetadata(contentType: 'image/jpeg'),
            );

            // Get download URL
            String downloadUrl = await storageRef.getDownloadURL();
            imageUrls.add(downloadUrl);
            print('Successfully uploaded image: $downloadUrl');
          } catch (e) {
            print('Error uploading image: $e');
          }
        }

        if (imageUrls.isEmpty) {
          print('No images were successfully uploaded');
          return;
        }

        // Create post document in Firestore
        final post = PostModel(
          text: state.text, // Use state.text instead of event.text
          imageUrls: imageUrls,
          tags: state.tags,
          createdAt: DateTime.now(), // Use state.tags
        );

        // Save to Firestore
        await _firestore.collection('posts').add(post.toMap());
        print(
            'Successfully saved post to Firestore with ${imageUrls.length} images');

        // Clear state after successful upload
        emit(PostState.initial());
      } catch (e) {
        print('Error during post submission: $e');
      }
    });
  }
}
