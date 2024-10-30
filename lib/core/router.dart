// lib/config/routes/app_router.dart
import 'package:flutter/material.dart'; // Material 임포트 추가
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/screens/auth/findid_screen.dart';
import 'package:onlyveyou/screens/auth/login_screen.dart';
import 'package:onlyveyou/screens/auth/signup_screen.dart';
import 'package:onlyveyou/screens/category/category_screen.dart';
import 'package:onlyveyou/screens/history/histoy_screen.dart';
import 'package:onlyveyou/screens/home/home_screen.dart';
import 'package:onlyveyou/screens/mypage/my_page_screen.dart';
import 'package:onlyveyou/screens/mypage/profile_edit_screen.dart';

import '../screens/search/search_screen.dart';
import '../widgets/bottom_navbar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/category',
          pageBuilder: (context, state) => _buildPageWithTransition(
              state, CategoryScreen()), //^ builder를 pageBuilder로 변경
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(state, Home()),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(state, HistoryScreen()),
        ),
        GoRoute(
          path: '/my',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(state, const MyPageScreen()),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => SearchScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/login', // 기본 로그인 화면
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
        path: '/profile_edit',
        pageBuilder: (context, state) => _buildPageWithTransition(
              state,
              const ProfileEditScreen(),
            )),
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

CustomTransitionPage<void> _buildPageWithTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
