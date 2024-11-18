import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

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

  Future<int> getCartItemsCount() async {
    try {
      // 1. 현재 사용자 ID 가져오기
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      if (userId.isEmpty) {
        print('사용자 ID가 없습니다.');
        return 0;
      }

      // 2. Firestore 인스턴스 가져오기
      final firestore = FirebaseFirestore.instance;

      // 3. users 컬렉션에서 해당 사용자의 문서 가져오기
      final userDoc = await firestore
          .collection('users')
          .doc(userId)
          .get();

      // 4. 문서가 존재하지 않는 경우
      if (!userDoc.exists) {
        print('사용자 문서가 존재하지 않습니다.');
        return 0;
      }

      // 5. cartItems 필드가 있는지 확인하고 길이 반환
      final data = userDoc.data();
      if (data != null && data.containsKey('cartItems')) {
        final cartItems = List<Map<String, dynamic>>.from(data['cartItems'] ?? []);
        return cartItems.length;
      }

      return 0;
    } on FirebaseException catch (e) {
      print('Firebase 에러: ${e.message}');
      return 0;
    } catch (e) {
      print('카트 아이템 개수 가져오기 실패: $e');
      return 0;
    }
  }

}
