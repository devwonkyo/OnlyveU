// lib/config/routes/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/screens/auth/login_screen.dart';
import 'package:onlyveyou/presentation/blocs/home/screens/bottom_navbar.dart';
import 'package:onlyveyou/presentation/blocs/home/screens/home_screen.dart';
import 'package:onlyveyou/presentation/screens/category_screen.dart';
import 'package:onlyveyou/presentation/screens/histoy_screen.dart';
import 'package:onlyveyou/presentation/screens/my_screen.dart';

import '../screens/search/search_screen.dart';

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
          builder: (context, state) => CategoryScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => Home(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => HistoryScreen(),
        ),
        GoRoute(
          path: '/my',
          builder: (context, state) => MyScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => SearchScreen(),
        ),
      ],
    ),
  ],
);
