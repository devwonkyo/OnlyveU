import 'package:flutter/material.dart';

class EmailEditScreen extends StatelessWidget {
  const EmailEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '이메일 변경',
        ),
      ),
    );
  }
}
