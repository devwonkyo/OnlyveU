import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onlyveyou/config/color.dart';

class ShakingIcon extends StatefulWidget {
  @override
  _ShakingIconState createState() => _ShakingIconState();
}

class _ShakingIconState extends State<ShakingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // 애니메이션을 반복하고 역방향으로도 실행
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: 0.2 * sin(_controller.value * 2 * 5), // 흔들리는 각도 조절
          child: Icon(
            Icons.spa,
            size: 48,
            color: AppsColor.pastelGreen,
          ),
        );
      },
    );
  }
}