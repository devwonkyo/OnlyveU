import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_bloc.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_event.dart' as postEvent;
import 'package:onlyveyou/blocs/shutter/shutterpost_bloc.dart' as postBloc;
import 'package:onlyveyou/blocs/shutter/shutterpost_event.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_state.dart';
import 'package:onlyveyou/widgets/product_tag_selector.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _textController = TextEditingController();

  void _handleTagsSelected(List<String> tags) {
    context.read<PostBloc>().add(UpdateTagsEvent(tags));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
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

      },
      child: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text('새 게시물'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (GoRouter.of(context).canPop()) {
                        GoRouter.of(context).pop();
                      } else {
                        GoRouter.of(context).go('/shutter');
                      }
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: (state.isLoading ||
                              !(state.images.isNotEmpty ||
                                  _textController.text.isNotEmpty))
                          ? null
                          : () {
                              context.read<PostBloc>().add(
                                    SubmitPostEvent(
                                      text: _textController.text,
                                      images: state.images,
                                      tags: state.tags,
                                    ),
                                  );
                              _textController.clear();
                            },
                      child: Text(
                        '올리기',
                        style: TextStyle(
                          color: (state.isLoading ||
                                  !(state.images.isNotEmpty ||
                                      _textController.text.isNotEmpty))
                              ? Colors.grey
                              : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: state.images.isEmpty ? 150 : 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: state.images.isEmpty
                              ? GestureDetector(
                                  onTap: state.isLoading
                                      ? null
                                      : () => _pickImage(context),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo,
                                          color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        '사진 추가',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : Stack(
                                  children: [
                                    SizedBox(
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state.images.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.file(
                                                    File(state
                                                        .images[index].path),
                                                    width: 120,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                if (!state.isLoading)
                                                  Positioned(
                                                    top: 4,
                                                    right: 4,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        final updatedImages =
                                                            List<XFile>.from(
                                                                state.images)
                                                              ..removeAt(index);
                                                        context
                                                            .read<PostBloc>()
                                                            .emit(state.copyWith(
                                                                images:
                                                                    updatedImages));
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black
                                                              .withOpacity(0.5),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        child: const Icon(
                                                          Icons.close,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      bottom: 8,
                                      child: GestureDetector(
                                        onTap: state.isLoading
                                            ? null
                                            : () => _pickImage(context),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.add_a_photo,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        if (state.images.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${state.images.length}개의 사진이 선택됨',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _textController,
                          enabled: !state.isLoading,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: '게시물 내용을 입력하세요...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (text) {
                            context.read<PostBloc>().add(UpdateTextEvent(text));
                          },
                        ),
                        const SizedBox(height: 16),
                        ProductTagSelector(
                          initialTags: state.tags,
                          onTagsSelected: _handleTagsSelected,
                          selectedColor: const Color(0xFFC9C138),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (state.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '게시물 업로드 중...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
