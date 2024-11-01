// lib/utils/firebase_utils.dart
import 'package:firebase_auth/firebase_auth.dart';

class AppConstants {
  // 일반적인 사용을 위한 getter
  static String get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? 'temp_user_id';
  }

  // 디버깅용 별도 메서드
  static void checkCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    print('=== Firebase Auth Status Check ===');
    print('User ID: ${user?.uid}');
    print('Email: ${user?.email}');
    print('Is Verified: ${user?.emailVerified}');
    print('===============================');
  }
}
