import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // 회원 탈퇴 메서드
  Future<void> deleteAccount() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      // Firestore에서 사용자 정보 삭제
      await _firestore.collection('users').doc(user.uid).delete();
      // Firebase Authentication에서 사용자 삭제
      await user.delete();
    }
  }
}
