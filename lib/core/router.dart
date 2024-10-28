import 'package:go_router/go_router.dart';
import 'package:onlyveyou/presentation/blocs/home/screens/home_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    // Auth 관련 Route
    GoRoute(
      path: '/home',
      builder: (context, state) => Home(),
    ),
  ],
);
