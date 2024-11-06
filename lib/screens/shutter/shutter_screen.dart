import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';
import 'package:onlyveyou/blocs/shutter/shutter_bloc.dart';
import 'package:onlyveyou/blocs/shutter/shutter_event.dart';
import 'package:onlyveyou/blocs/shutter/shutter_state.dart';
import 'package:onlyveyou/screens/shutter/shutter_post.dart';

class ShutterScreen extends StatelessWidget {
  const ShutterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShutterBloc(),
      child: Scaffold(
        appBar: DefaultAppBar(mainColor: const Color(0xFFC9C138)),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 기존 UI: 헤더와 태그 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SHUTTER',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/shutterpost');
                      },
                      child: Text(
                        '글쓰기 >',
                        style: TextStyle(
                          color: const Color(0xFFC9C138),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '요즘 인기있는',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                BlocBuilder<ShutterBloc, ShutterState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTagButton(
                              context, '#데일리메이크업', state.selectedTag),
                          _buildTagButton(context, '#틴트', state.selectedTag),
                          _buildTagButton(context, '#홈케어', state.selectedTag),
                          _buildTagButton(context, '#건강관리', state.selectedTag),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<ShutterBloc, ShutterState>(
                  builder: (context, state) {
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(state.images.length,
                          (index) => _buildProfileCard(state.images[index])),
                    );
                  },
                ),

                // 새로운 게시물 섹션 추가
                const SizedBox(height: 40),
                Text(
                  '게시물',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    _buildPost(
                      imagePath: 'assets/image/shutter/sample1.jpg',
                      username: 'user123',
                      description: '오늘의 뷰티 팁!',
                      likes: 125,
                      comments: 12,
                    ),
                    _buildPost(
                      imagePath: 'assets/image/shutter/sample2.jpg',
                      username: 'beauty_queen',
                      description: '새로 산 립스틱 색상!',
                      likes: 80,
                      comments: 5,
                    ),
                    _buildPost(
                      imagePath: 'assets/images/sample3.jpg',
                      username: 'makeup_lover',
                      description: '간단한 데일리 메이크업!',
                      likes: 200,
                      comments: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagButton(BuildContext context, String tag, String selectedTag) {
    bool isSelected = tag == selectedTag;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
          context.read<ShutterBloc>().add(TagSelected(tag));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.black),
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String imagePath) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            print('이미지를 클릭했습니다!');
          },
          child: Container(
            width: 165,
            height: 165,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // 게시물 UI 구성
  Widget _buildPost({
    required String imagePath,
    required String username,
    required String description,
    required int likes,
    required int comments,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 게시물 이미지
          Image.asset(imagePath),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자명과 설명
                Text(
                  username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(description),
                const SizedBox(height: 10),
                // 좋아요, 댓글
                Row(
                  children: [
                    Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text('$likes likes'),
                    const SizedBox(width: 10),
                    Icon(Icons.comment, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text('$comments comments'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
