import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_event.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_bloc.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_state.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      context.read<PostBloc>().add(AddImageEvent(pickedFile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state.text.isEmpty && state.images.isEmpty) {
          GoRouter.of(context).go('/shutter');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('새 게시물'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
              } else {
                GoRouter.of(context).go('/shutter');
              }
            },
          ),
          actions: [
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                final isButtonEnabled =
                    state.images.isNotEmpty || _textController.text.isNotEmpty;

                return TextButton(
                  onPressed: isButtonEnabled
                      ? () {
                          context.read<PostBloc>().add(SubmitPostEvent(
                                text: _textController.text,
                                images: state.images,
                                tags: state.tags,
                              ));
                          _textController.clear();
                        }
                      : null,
                  child: Text(
                    '올리기',
                    style: TextStyle(
                      color: isButtonEnabled ? Colors.blue : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지 추가 버튼 및 미리보기
                    GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: state.images.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      '사진 추가',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.images.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.file(
                                              File(state.images[index].path),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              final updatedImages =
                                                  List<XFile>.from(state.images)
                                                    ..removeAt(index);
                                              context.read<PostBloc>().emit(
                                                  state.copyWith(
                                                      images: updatedImages));
                                            },
                                            child: CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Colors.black45,
                                              child: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    if (state.images.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '${state.images.length}개의 사진이 선택됨',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    SizedBox(height: 16),
                    // 게시물 텍스트 입력 필드
                    TextField(
                      controller: _textController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: '게시물 내용을 입력하세요...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        context.read<PostBloc>().add(UpdateTextEvent(text));
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
