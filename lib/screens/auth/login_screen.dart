import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onlyveyou/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/auth/auth_event.dart';
import 'package:onlyveyou/blocs/auth/auth_state.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/screens/auth/widgets/shaking_icon.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/user_model.dart';
import 'package:onlyveyou/utils/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late final String token;
  bool autoLogin = false;
  final _prefs = OnlyYouSharedPreference();

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadAutoLoginState();
  }

  Future<void> _loadAutoLoginState() async {
    autoLogin = await _prefs.getAutoLogin();
    setState(() {});
  }

  Future<void> _handleLogin(BuildContext context, String userId) async {
    if (autoLogin) {
      await _prefs.setAutoLogin(true);
    } else {
      await _prefs.setAutoLogin(false);
    }
    await _saveUserInfoToSharedPrefs(userId);
  }

  // SharedPreferences에서 토큰을 가져오는 메서드
  Future<void> _loadToken() async {
    try {
      final loadedToken = await OnlyYouSharedPreference().getToken();
      if (mounted) {
        // setState 전에 위젯이 여전히 트리에 있는지 확인
        setState(() {
          token = loadedToken;
        });
      }
      print('Loaded token: $token'); // 디버깅용
    } catch (e) {
      print('Error loading token: $e');
      if (mounted) {
        setState(() {
          token = ''; // 에러 발생 시 토큰을 null로 설정
        });
      }
    }
  }

  Future<void> _saveUserModelToFirestore(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      print("Firestore에 유저 모델 저장 오류: $e");
    }
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
              child: const Text('확인'),
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
        String userId = userDoc.get('uid');
        String email = userDoc.get('email');
        String gender = userDoc.get('gender');
        String nickname = userDoc.get('nickname');
        String phone = userDoc.get('phone');

        // SharedPreferences에 저장
        await OnlyYouSharedPreference().setUserId(userId);
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
      await kakao.UserApi.instance.loginWithKakaoAccount();
      // await kakao.UserApi.instance.loginWithKakaoTalk();
      print("kakao login");
    } catch (error) {

      print("kakao login error ");
    }

    try {
      kakao.User kakaoUser = await kakao.UserApi.instance.me();

      String uid = kakaoUser.id.toString();
      String email = kakaoUser.kakaoAccount?.email ?? '';
      String nickname = kakaoUser.kakaoAccount?.profile?.nickname ?? '';

      // UserModel 인스턴스 생성
      UserModel userModel = UserModel(
        uid: uid,
        email: email,
        nickname: nickname,
        token: token,
      );

      // Firebase Firestore에 UserModel 저장
      await _saveUserModelToFirestore(userModel);

      //sharedpreferenc에 저장
      _saveUserInfoToSharedPrefs(uid);

      context.go('/home'); // 홈 화면으로 이동
    } catch (e) {
      print("카카오 로그인 실패: $e");
      _showDialog("카카오 로그인에 실패했습니다.");
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // 자동 로그인 설정 저장
        if (autoLogin) {
          await _prefs.setAutoLogin(true);
        } else {
          await _prefs.setAutoLogin(false);
        }

        // UserModel 인스턴스 생성
        UserModel userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          nickname: user.displayName ?? '',
          token: token ?? '',
        );

        // Firebase Firestore에 UserModel 저장
        await _saveUserModelToFirestore(userModel);

        // SharedPreferences에 저장
        await _saveUserInfoToSharedPrefs(user.uid);

        context.go('/home'); // 홈 화면으로 이동
      }
    } catch (e) {
      print("구글 로그인 실패: $e");
      _showDialog("구글 로그인에 실패했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        } else if (state is LoginSuccess) {
          Navigator.of(context).pop();
          _handleLogin(context, state.userId);
          context.go('/home');
        } else if (state is LoginFailure) {
          Navigator.of(context).pop();
          _showDialog(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            '당신만을 위한',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '쇼핑공간',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Onlyve',
                              style: TextStyle(
                                fontSize: 48,
                                color: AppsColor.pastelGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ShakingIcon()
                          ],
                        ),
                        const SizedBox(height: 50),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            hintText: '이메일',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder( // 포커스 받았을 때 테두리
                              borderSide: BorderSide(
                                color: AppsColor.pastelGreen, // 원하는 색상으로 변경
                                width: 2.0, // 테두리 두께
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: '비밀번호',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder( // 포커스 받았을 때 테두리
                              borderSide: BorderSide(
                                color: AppsColor.pastelGreen, // 원하는 색상으로 변경
                                width: 2.0, // 테두리 두께
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('자동 로그인'),
                            Switch(
                              value: autoLogin,
                              onChanged: (bool value) {
                                setState(() {
                                  autoLogin = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.mainColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () {
                            context.read<AuthBloc>().add(LoginRequested(
                                  email: emailController.text,
                                  password: passwordController.text,
                                ));
                          },
                          child: const Text('이메일 로그인',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 60),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _loginWithKakao();
                              },
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: AppsColor.kakaoYello,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    'assets/image/kakao_icon.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                _loginWithGoogle();
                              },
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: AppsColor.googleBlue,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset(
                                    'assets/image/google_icon.png',
                                    fit: BoxFit.contain,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '계정이 없으신가요?',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/signup');
                      },
                      child: const Text(
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
    );
  }
}
