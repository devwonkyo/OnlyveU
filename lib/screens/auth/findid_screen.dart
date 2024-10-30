import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FindIdScreen extends StatefulWidget {
  @override
  _FindIdScreenState createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  final TextEditingController _identifierController = TextEditingController();

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                '아이디 찾기',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 40),
            TextField(
              controller: _identifierController,
              decoration: InputDecoration(
                hintText: '전화번호 또는 이메일',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // 아이디 찾기 로직 추가
                String identifier = _identifierController.text;
                if (identifier.isNotEmpty) {
                  // 아이디 찾기 기능 구현
                  // 예: API 호출 또는 Firebase와 연동
                  print("아이디 찾기 요청: $identifier");
                } else {
                  // 입력 값이 없을 경우 경고 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('전화번호 또는 이메일을 입력하세요.')),
                  );
                }
              },
              child: Text('아이디 찾기', style: TextStyle(color: Colors.white)),
            ),
            Spacer(),
            Center(
              child: Column(
                children: [
                  Text(
                    '아이디를 찾으셨나요?',
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
    );
  }
}
