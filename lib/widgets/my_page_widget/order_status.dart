import 'package:flutter/material.dart';

// 숫자와 상태 텍스트를 수직으로 배치하는 함수(주문 배송 조회 아래 위젯)
class OrderStatus extends StatelessWidget {
  final String count;
  final String label;

  const OrderStatus(this.count, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
