import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color mainColor;

  DefaultAppBar({Key? key, required this.mainColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.spa, color: mainColor),
          const SizedBox(width: 8),
          const Text(
            '온니브유',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            "Only'veU",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () => context.go('/search'), // 검색 화면으로 이동
        ),
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
