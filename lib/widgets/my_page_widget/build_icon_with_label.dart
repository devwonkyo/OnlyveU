// 아이콘과 텍스트를 수직으로 배치하는 위젯(Cj one, 쿠폰, 기프트 카드, 멤버십 바코드)
import 'package:flutter/material.dart';

Widget BuildIconWithLabel(
    IconData icon, String title, String subtitle, VoidCallback onPressed) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero, // 패딩 제거
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      foregroundColor: Colors.black,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 36),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
      ],
    ),
  );
}
