import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

class TokenCheck extends StatefulWidget {
  @override
  _TokenCheckState createState() => _TokenCheckState();
}

class _TokenCheckState extends State<TokenCheck> {
  final _prefs = OnlyYouSharedPreference();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    bool isAutoLogin = await _prefs.getAutoLogin();
    String userId = await _prefs.getCurrentUserId();

    // Firebase의 현재 로그인된 사용자 확인
    User? currentUser = _auth.currentUser;

    if (isAutoLogin && currentUser != null) {
      // 자동 로그인이 활성화되어 있고, Firebase에 현재 사용자가 있으면 홈으로 이동
      try {
        // ID 토큰 갱신
        await currentUser.getIdToken(true);
        context.go('/home');
      } catch (e) {
        // 토큰 갱신 실패 시 로그인 페이지로 이동
        print("토큰 갱신 실패: $e");
        context.go('/login');
      }
    } else {
      // 그렇지 않으면 로그인 페이지로 이동
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
