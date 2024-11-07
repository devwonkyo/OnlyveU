import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/auth/auth_event.dart';
import 'package:onlyveyou/blocs/auth/auth_state.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // 로딩 다이얼로그 표시
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(child: CircularProgressIndicator()),
          );
        } else if (state is SignUpSuccess) {
          Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
          showDialog(
            context: context,
            barrierDismissible: false, // 다이얼로그 바깥 터치로 닫기 방지
            builder: (context) => AlertDialog(
              content: Text('회원가입이 완료되었습니다! 이메일 인증 완료 후 로그인 해주세요.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    context.pop(); // 이전 화면으로 이동
                  },
                  child: Text('확인'),
                ),
              ],
            ),
          );
        } else if (state is AuthFailure) {
          Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
          _showDialog(state.message); // 실패 메시지 표시
        }
      },
      child: Scaffold(
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
          onTap: () => FocusScope.of(context).unfocus(),
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
                    hintText: '이메일',
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
                  onPressed: () {
                    context.read<AuthBloc>().add(SignUpRequested(
                          email: idController.text,
                          password: passwordController.text,
                          nickname: nicknameController.text,
                          phone: phoneController.text,
                          gender: selectedGenderIndex == 0 ? '남성' : '여성',
                        ));
                  },
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
      ),
    );
  }
}
