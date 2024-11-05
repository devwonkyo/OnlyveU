import 'package:flutter/material.dart';

class LaterTabScreen extends StatelessWidget {
  const LaterTabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '나중에 컨텐츠',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
