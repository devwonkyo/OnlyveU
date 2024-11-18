import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/shutter/shutter_bloc.dart';
import 'package:onlyveyou/blocs/shutter/shutter_event.dart';
import 'package:onlyveyou/blocs/shutter/shutter_state.dart';
import 'package:onlyveyou/models/post_model.dart';
import 'package:onlyveyou/screens/shutter/firestore_service.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';

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

                  return ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(post
                                        .imageUrls.isNotEmpty
                                    ? post.imageUrls.first
                                    : 'https://via.placeholder.com/150'), // 이미지 표시
                              ),
                              title: Text(post.authorName), // 작성자 이름
                              subtitle: Text(
                                post.createdAt.toString(), // 작성 시간
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(post.text), // 본문 텍스트
                            ),
                            if (post.imageUrls.isNotEmpty) // 이미지가 있을 경우 표시
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.imageUrls.length,
                                  itemBuilder: (context, imgIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(
                                        post.imageUrls[imgIndex],
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            Wrap(
                              spacing: 8.0,
                              children: post.tags
                                  .map((tag) => Chip(label: Text(tag))) // 태그 표시
                                  .toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display image if available
          if (post.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                post.imageUrls[0],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              ),
            ),
          // Post content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post text
                Text(
                  post.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Post created date
                Text(
                  '${post.createdAt.year}년 ${post.createdAt.month}월 ${post.createdAt.day}일',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // Post author name
                Text(
                  '작성자: ${post.authorName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                // Post tags
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: post.tags
                        .map((tag) => Chip(
                              label: Text('#$tag'),
                              backgroundColor:
                                  const Color(0xFFC9C138).withOpacity(0.2),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
