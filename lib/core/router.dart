import 'package:go_router/go_router.dart';
import 'package:onlyveyou/screens/auth/login_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    // Auth 관련 Route
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
  ],
);
