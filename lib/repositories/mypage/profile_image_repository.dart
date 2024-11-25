import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileImageRepository {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadProfileImage(String userId, File image) async {
    try {
      // Firebase Storage에 이미지 업로드
      final ref = _firebaseStorage
          .ref()
          .child('profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        // 업로드된 이미지의 URL 가져오기
        return await ref.getDownloadURL();
      } else {
        throw Exception("Failed to upload image");
      }
    } catch (e) {
      throw Exception("Error uploading profile image: $e");
    }
  }

  Future<void> saveProfileImageUrl(String userId, String imageUrl) async {
    try {
      // Firestore에 프로필 이미지 URL 저장
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception("Error saving profile image URL: $e");
    }
  }

  Future<String?> getProfileImageUrl(String userId) async {
    try {
      // Firestore에서 프로필 이미지 URL 가져오기
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['profileImageUrl'];
    } catch (e) {
      throw Exception("Error fetching profile image URL: $e");
    }
  }
}
