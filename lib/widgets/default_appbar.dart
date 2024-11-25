import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/config/color.dart'; // AppsColor import 추가

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color mainColor;

  const DefaultAppBar({super.key, required this.mainColor});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDarkMode ? AppsColor.darkGray : Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.spa, color: mainColor),
          const SizedBox(width: 8),
          Text(
            '온니브유',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "Only'veU",
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            context.push('/search');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.shopping_bag_outlined,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            context.push('/cart');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
