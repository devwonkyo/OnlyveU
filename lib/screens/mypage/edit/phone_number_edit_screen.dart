import 'package:flutter/material.dart';

class PhoneNumberEditScreen extends StatelessWidget {
  const PhoneNumberEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '휴대폰 번호 변경',
        ),
      ),
    );
  }
}
