import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/core/router.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _autoLogin = false;
  bool _saveId = false;
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    'ONLY`ve YOU',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: '이메일 주소',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호 (8~12자, 영문+숫자)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _autoLogin,
                  onChanged: (bool? value) {
                    setState(() {
                      _autoLogin = value!;
                    });
                  },
                ),
                Text('자동로그인'),
                SizedBox(width: 10),
                Checkbox(
                  value: _saveId,
                  onChanged: (bool? value) {
                    setState(() {
                      _saveId = value!;
                    });
                  },
                ),
                Text('아이디 저장'),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _signInWithEmailAndPassword, // 로그인 함수 호출
              child: Text('로그인', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    context.go('/find-id'); // 아이디 찾기 화면으로 이동
                  },
                  child: Text('아이디 찾기', style: TextStyle(color: Colors.black)),
                ),
                Text('|', style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {
                    // 비밀번호 찾기 화면으로 이동하는 코드 작성
                  },
                  child: Text('비밀번호 찾기', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {},
              icon: Icon(Icons.chat_bubble, color: Colors.black),
              label: Text('카카오로 로그인', style: TextStyle(color: Colors.black)),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: Colors.grey),
              ),
              onPressed: () {},
              icon: Icon(Icons.g_mobiledata_outlined, color: Colors.black),
              label: Text('Google로 로그인', style: TextStyle(color: Colors.black)),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: Colors.grey),
              ),
              onPressed: () {
                context.go('/signup'); // 회원가입 화면으로 이동
              },
              child: Text('회원가입', style: TextStyle(color: Colors.black)),
            ),
            Spacer(),
            Center(
              child: Column(
                children: [
                  Text(
                    'ver 3.18.0 최신 버전    캐시 데이터 삭제    오픈 라이센스',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '고객센터 · 공지사항',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _idController.text,
        password: _passwordController.text,
      );
      // 로그인 성공 시 다음 화면으로 이동 (예: 홈 화면)
      context.go('/home');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = '사용자를 찾을 수 없습니다.';
      } else if (e.code == 'wrong-password') {
        message = '비밀번호가 틀렸습니다.';
      } else {
        message = '로그인에 실패했습니다.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
