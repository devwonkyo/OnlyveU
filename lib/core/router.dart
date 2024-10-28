import 'package:go_router/go_router.dart';
import 'package:onlyveyou/presentation/blocs/auth/screens/login_screen.dart';

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
