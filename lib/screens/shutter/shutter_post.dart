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
    return BlocProvider(
      create: (context) => PostBloc(),
      child: BlocListener<PostBloc, PostState>(
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
                }),
            actions: [
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  return TextButton(
                    onPressed: state.images.isEmpty
                        ? null
                        : () {
                            context.read<PostBloc>().add(SubmitPostEvent(
                                  text: _textController.text,
                                  images: state.images,
                                  tags: state.tags,
                                ));
                            _textController.clear();
                          },
                    child: Text(
                      '올리기',
                      style: TextStyle(
                        color: state.images.isEmpty ? Colors.grey : Colors.blue,
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
                      GestureDetector(
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
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(state.images.first.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      if (state.images.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '${state.images.length}장의 사진이 선택됨',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      SizedBox(height: 16),
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
