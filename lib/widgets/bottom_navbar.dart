// bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Color mainColor;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.mainColor,
  }) : super(key: key);

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/category');
        break;
      case 1:
        context.go('/home');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/my');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: mainColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: '카테고리',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: '히스토리',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '마이',
        ),
      ],
    );
  }
}

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentPath = GoRouterState.of(context).uri.toString();
    int currentIndex = _calculateSelectedIndex(currentPath);

    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        mainColor: const Color(0xFFC9C138),
      ),
    );
  }

  int _calculateSelectedIndex(String currentPath) {
    if (currentPath.startsWith('/category')) return 0;
    if (currentPath.startsWith('/home')) return 1;
    if (currentPath.startsWith('/history')) return 2;
    if (currentPath.startsWith('/my')) return 3;
    return 1; // 기본값은 홈
  }
}
