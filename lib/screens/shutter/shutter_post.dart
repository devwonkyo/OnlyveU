// post_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_event.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_bloc.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_state.dart';

class PostScreen extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      context.read<PostBloc>().add(AddImageEvent(pickedFile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('새 게시물'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (GoRouter.of(context).canPop()) {
                  GoRouter.of(context).pop(); // Safely pop if possible
                } else {
                  GoRouter.of(context)
                      .go('/shutter'); // Example redirect to home
                }
              }),
          actions: [
            TextButton(
              onPressed: () {
                final text = _textController.text; // 텍스트 입력값
                final images =
                    context.read<PostBloc>().state.images; // 현재 선택된 이미지 리스트

                context.read<PostBloc>().add(SubmitPostEvent(
                      text: text, // 텍스트를 전달
                      images: images, // 이미지 리스트를 전달
                      tags: [], // 태그 추가 시 필요
                    ));
              },
              child: Text(
                '올리기',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () => _pickImage(context),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: state.images.isEmpty
                            ? Icon(Icons.add, color: Colors.grey)
                            : Stack(
                                children: state.images
                                    .map(
                                      (image) => Image.file(
                                        File(image.path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              Text(
                '사용한 상품과 다양한 팁을 공유해 보세요.\n- 상품 추천, 사용 후기, 발색 비교 등',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 10),
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  _textController.text = state.text;
                  return TextField(
                    controller: _textController,
                    maxLines: null,
                    onChanged: (text) {
                      context.read<PostBloc>().add(UpdateTextEvent(text));
                    },
                    decoration: InputDecoration(
                      hintText: '내용을 입력하세요',
                      border: InputBorder.none,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // 태그 추가 로직 구현
                    },
                    icon: Icon(Icons.tag, color: Colors.grey),
                    label:
                        Text('# 태그 (선택)', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(),
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.grey),
                title: Text('게시물 리워드 안내'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('게시물을 등록하시면 다양한 리워드를 받을 수 있습니다.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
