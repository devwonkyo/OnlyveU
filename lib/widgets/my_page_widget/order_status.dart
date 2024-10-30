import 'package:flutter/material.dart';

// 숫자와 상태 텍스트를 수직으로 배치하는 함수(주문 배송 조회 아래 위젯)
Widget OrderStatus(String count, String label) {
  return Column(
    children: [
      Text(
        count,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade400,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
      ),
    ],
  );
}
