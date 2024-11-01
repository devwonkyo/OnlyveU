// Firebase 사용자 ID 관리
import 'package:firebase_auth/firebase_auth.dart';

class AppConstants {
  static String get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? 'temp_user_id';
  }
}
