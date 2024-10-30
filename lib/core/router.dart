import 'package:go_router/go_router.dart';
import 'package:onlyveyou/screens/auth/login_screen.dart';
import 'package:onlyveyou/screens/auth/signup_screen.dart';
import 'package:onlyveyou/screens/auth/findid_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login', // 앱 시작 시 보여줄 경로
  routes: [
    // Auth 관련 Route
    GoRoute(
      path: '/login', // 기본 로그인 화면
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/signup', // 회원가입 화면
      builder: (context, state) => SignupScreen(),
    ),
    GoRoute(
      path: '/find-id',
      builder: (context, state) => FindIdScreen(),
    ),
  ],
);
