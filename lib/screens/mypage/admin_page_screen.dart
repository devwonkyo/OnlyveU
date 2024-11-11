import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/firebase_data_uploader.dart';

class AdminPageScreen extends StatelessWidget {
  const AdminPageScreen({super.key});

  // 각 버튼별 동작 함수 -밑에서 버튼이름 바꿀 수 있어요

  void _onTapButton1() async {
    //파베 DB에 화장품 올리기
    // async 추가
    try {
      final uploader = FirebaseDataUploader();
      await uploader.initializeDatabase();
      print('더미데이터 업로드 완료');
    } catch (e) {
      print('업로드 실패: $e');
    }
  }

  void _onTapButton2() {
    print('버튼2가 눌렸습니다');
  }

  void _onTapButton3() {
    print('버튼3이 눌렸습니다');
  }

  void _onTapButton4() {
    print('버튼4가 눌렸습니다');
  }

  void _onTapButton5() {
    print('버튼5가 눌렸습니다');
  }

  void _onTapButton6() {
    print('버튼6이 눌렸습니다');
  }

  // 공통 버튼 위젯
  Widget _buildAdminButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '관리자 페이지',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          children: [
            // 버튼이름 여기서 바꾸세요
            _buildAdminButton(text: '화장품들 DB에 올림', onPressed: _onTapButton1),
            _buildAdminButton(text: '빈칸2', onPressed: _onTapButton2),
            _buildAdminButton(text: '빈칸3', onPressed: _onTapButton3),
            _buildAdminButton(text: '빈칸4', onPressed: _onTapButton4),
            _buildAdminButton(text: '빈칸5', onPressed: _onTapButton5),
            _buildAdminButton(text: '빈칸6', onPressed: _onTapButton6),
          ],
        ),
      ),
    );
  }
}
