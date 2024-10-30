import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int selectedGenderIndex = 0; // 0: 남성, 1: 여성
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void _signup() {
    // 회원가입 로직 구현
    final String id = idController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;
    final String nickname = nicknameController.text;
    final String phone = phoneController.text;

    // 간단한 유효성 검사 예시
    if (id.length < 6) {
      _showDialog('아이디는 6자 이상이어야 합니다.');
      return;
    }
    if (password.length < 8 || password.length > 12) {
      _showDialog('비밀번호는 8~12자이어야 합니다.');
      return;
    }
    if (password != confirmPassword) {
      _showDialog('비밀번호가 일치하지 않습니다.');
      return;
    }
    // 회원가입 성공 메시지
    _showDialog('회원가입이 완료되었습니다!');
    // 실제 회원가입 로직을 여기서 구현하세요.
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            context.pop(); // 이전 화면으로 돌아가기
          },
        ),
      ),
      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // Tap to dismiss keyboard
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Center(
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  hintText: '아이디 (6자 이상, 영문+숫자)',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호 (8~12자, 영문+숫자)',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호 확인',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nicknameController,
                decoration: InputDecoration(
                  hintText: '닉네임',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '전화번호',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '성별',
                    style: TextStyle(fontSize: 16),
                  ),
                  ToggleButtons(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('남성'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('여성'),
                      ),
                    ],
                    isSelected: [
                      selectedGenderIndex == 0,
                      selectedGenderIndex == 1
                    ],
                    onPressed: (int index) {
                      setState(() {
                        selectedGenderIndex = index;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _signup,
                child: Text('회원가입', style: TextStyle(color: Colors.white)),
              ),
              Spacer(),
              Center(
                child: Column(
                  children: [
                    Text(
                      '이미 계정이 있으신가요?',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/login'); // 로그인 화면으로 이동
                      },
                      child: Text(
                        '로그인',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
