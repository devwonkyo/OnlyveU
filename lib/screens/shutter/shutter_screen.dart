import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/shutter/shutter_bloc.dart';
import 'package:onlyveyou/blocs/shutter/shutter_event.dart';
import 'package:onlyveyou/blocs/shutter/shutter_state.dart';
import 'package:onlyveyou/models/post_model.dart';
import 'package:onlyveyou/screens/shutter/firestore_service.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';
import 'package:intl/intl.dart';

class ShutterScreen extends StatelessWidget {
  const ShutterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShutterBloc(FirestoreService())..add(FetchPosts()),
      child: Scaffold(
        appBar: DefaultAppBar(mainColor: const Color(0xFFC9C138)),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
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
                    child: const Text(
                      '글쓰기 >',
                      style: TextStyle(
                        color: Color(0xFFC9C138),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Posts List
              Expanded(child: BlocBuilder<ShutterBloc, ShutterState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (state.posts.isEmpty) {
                    return Center(child: Text('No posts available.'));
                  }

                  return ListView.separated(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/post-detail', extra: post);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post Info
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  post.authorProfileImageUrl.isNotEmpty
                                      ? post.authorProfileImageUrl
                                      : 'https://via.placeholder.com/150', // 기본 프로필 이미지
                                ),
                              ),
                              title: Text(post.authorName),
                              subtitle: Text(
                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(post.createdAt),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(post.text), // 본문 텍스트
                            ),
                            // Image Gallery
                            if (post.imageUrls.isNotEmpty)
                              SizedBox(
                                height: 300, // 적절한 이미지 높이 설정
                                child: PageView.builder(
                                  itemCount: post.imageUrls.length,
                                  itemBuilder: (context, imgIndex) {
                                    return Image.network(
                                      post.imageUrls[imgIndex],
                                      width: MediaQuery.of(context)
                                          .size
                                          .width, // 화면 크기에 맞추기
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            // Post Tags
                            if (post.tags.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  children: post.tags
                                      .map((tag) =>
                                          Chip(label: Text(tag))) // 태그 표시
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(), // 구분선 추가
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
