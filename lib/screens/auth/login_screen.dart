import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/auth/auth_event.dart';
import 'package:onlyveyou/blocs/auth/auth_state.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

  Future<void> _saveUserInfoToSharedPrefs(String userId) async {
    try {
      // Firebase에서 유저 정보 가져오기
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Firebase에서 가져온 데이터
        String email = userDoc.get('email');
        String gender = userDoc.get('gender');
        String nickname = userDoc.get('nickname');
        String phone = userDoc.get('phone');

        // SharedPreferences에 저장
        await OnlyYouSharedPreference().setEmail(email);
        await OnlyYouSharedPreference().setGender(gender);
        await OnlyYouSharedPreference().setNickname(nickname);
        await OnlyYouSharedPreference().setPhone(phone);
      }
    } catch (e) {
      print("유저 정보 저장 오류: $e");
    }
  }

  Future<void> _loginWithKakao() async {
    try {
      // 카카오톡 로그인 시도, 실패하면 계정 로그인 시도
      try {
        await kakao.UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        // 카카오톡 로그인이 실패했을 때 계정으로 로그인 시도
        await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 로그인 성공 시 사용자 정보 확인
      kakao.User kakaoUser = await kakao.UserApi.instance.me();

      // 유저 정보 로컬에 저장 (필요시)
      await OnlyYouSharedPreference()
          .setEmail(kakaoUser.kakaoAccount?.email ?? '');
      await OnlyYouSharedPreference()
          .setNickname(kakaoUser.kakaoAccount?.profile?.nickname ?? '');

      // 로그인 성공 후 홈 화면으로 이동
      context.go('/home');
    } catch (e) {
      print("카카오 로그인 실패: $e");
      _showDialog("카카오 로그인에 실패했습니다.");
    }
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
        } else if (state is LoginSuccess) {
          Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
          _saveUserInfoToSharedPrefs(state.userId); // 로그인 성공 시 유저 정보 저장
          context.go('/home'); // 홈 화면으로 이동
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
                    '로그인',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: emailController,
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
                    hintText: '비밀번호',
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
                    context.read<AuthBloc>().add(LoginRequested(
                          email: emailController.text,
                          password: passwordController.text,
                        ));
                  },
                  child: Text('로그인', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    _loginWithKakao(); // 카카오 로그인 기능 호출
                  },
                  child:
                      Text('카카오톡으로 로그인', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Colors.black),
                  ),
                  onPressed: () {
                    // 구글 로그인 기능 추가
                  },
                  child: Text('구글로 로그인', style: TextStyle(color: Colors.black)),
                ),
                Spacer(),
                Center(
                  child: Column(
                    children: [
                      Text(
                        '계정이 없으신가요?',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/signup'); // 회원가입 화면으로 이동
                        },
                        child: Text(
                          '회원가입',
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
