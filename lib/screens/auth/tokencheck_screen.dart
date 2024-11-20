import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

class TokenCheck extends StatefulWidget {
  @override
  _TokenCheckState createState() => _TokenCheckState();
}

class _TokenCheckState extends State<TokenCheck> {
  final _prefs = OnlyYouSharedPreference();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    bool isAutoLogin = await _prefs.getAutoLogin();
    String userId = await _prefs.getCurrentUserId();

    if (isAutoLogin && userId != 'temp_user_id') {
      // 자동 로그인이 활성화되어 있고, 유저 ID가 존재하면 홈으로 이동
      context.go('/home');
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
