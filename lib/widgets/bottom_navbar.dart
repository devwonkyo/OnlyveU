// bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Color mainColor;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.mainColor,
  });

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
      backgroundColor: Theme.of(context)
          .bottomNavigationBarTheme
          .backgroundColor, // 테마의 색상 사용
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

  const ScaffoldWithBottomNavBar({super.key, required this.child});

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
    if (currentPath.startsWith('/profile_edit')) return 3;
    if (currentPath.startsWith('/order-status')) return 3;
    return 1; // 기본값은 홈
  }
}

//블록의 equitable
//다른데서는 같은 state1=10 , state2=10 일때
//똑같은 10이라 다른객체로 인식되서 다시 렌더링함
//
//이쿼터블을 쓰면 상태가 같더라고 다른 객체로 인식함
//값으로 인식해서 같은 값이면 렌더링을 안한다.
//
//다른 렌더링 해서 성능적인 부분에서 이득이 있다
//
//prox 에서 값을 저장해서 비교한다.
