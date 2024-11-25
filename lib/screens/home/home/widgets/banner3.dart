import 'package:flutter/material.dart';

class Banner3Screen extends StatelessWidget {
  const Banner3Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 배너 이미지 리스트
    final List<String> bannerImages = [
      'assets/image/banner/d1.png', // 첫 번째 이미지
      'assets/image/banner/d2.jfif',
      'assets/image/banner/d3.jfif',
      'assets/image/banner/d4.jfif',
      'assets/image/banner/d5.jfif',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: bannerImages
              .map(
                (imagePath) => Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
