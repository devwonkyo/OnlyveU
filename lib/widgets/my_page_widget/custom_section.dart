import 'package:flutter/material.dart';

class CustomSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const CustomSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(children: items),
        const Divider(height: 32, color: Colors.grey),
      ],
    );
  }
}

// 재사용 가능한 리스트 항목 생성 함수

Widget buildListItem(
  IconData icon,
  String title, {
  String? subtitle,
  VoidCallback? onTap, // onTap을 매개변수로 추가
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: subtitle != null
        ? Text(subtitle, style: const TextStyle(color: Colors.grey))
        : null,
    onTap: onTap, // onTap 매개변수 사용
  );
}
