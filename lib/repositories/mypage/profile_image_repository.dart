import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

//firebase_storage에 저장 후 url을 firestore에 저장 -> flutter에서는 firestore에 있는 url 사용
class ProfileImageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String userId) async {
    // Firebase Storage에 이미지 업로드
    final storageRef = _storage.ref().child('profile_images/$userId.jpg');
    await storageRef.putFile(imageFile);

    // 이미지의 다운로드 URL 가져오기
    String downloadUrl = await storageRef.getDownloadURL();
    // Firestore에 이미지 URL 저장
    await _firestore.collection('users').doc(userId).update({
      'profileImageUrl': downloadUrl,
    });
    return downloadUrl;
  }
}
