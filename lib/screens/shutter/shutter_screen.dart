import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';
import 'package:onlyveyou/blocs/shutter/shutter_bloc.dart';
import 'package:onlyveyou/screens/shutter/firestore_service.dart';
import 'package:onlyveyou/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              const Text(
                '요즘 인기있는',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              BlocBuilder<ShutterBloc, ShutterState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.error != null) {
                    return Center(child: Text('Error: ${state.error}'));
                  }

                  if (state.posts.isEmpty) {
                    return const Center(
                      child: Text('아직 게시물이 없습니다.'),
                    );
                  }

                  return Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<ShutterBloc>().add(FetchPosts());
                      },
                      child: ListView.builder(
                        itemCount: state.posts.length,
                        itemBuilder: (context, index) {
                          final post = state.posts[index];
                          return _buildPostWithActions(post);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostWithActions(PostModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${post.createdAt.year}년 ${post.createdAt.month}월 ${post.createdAt.day}일',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                // 현재 로그인된 사용자 정보 불러오기
                FutureBuilder<User?>(
                  future: _getCurrentUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Text('로그인되지 않았습니다.');
                    }

                    final currentUser = snapshot.data!;
                    return Text(
                      '작성자: ${currentUser.email ?? "알 수 없음"}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    );
                  },
                ),
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

  // FirebaseAuth에서 현재 로그인된 사용자 가져오기
  Future<User?> _getCurrentUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      return currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}
