import 'package:cloud_firestore/cloud_firestore.dart';
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
              Expanded(
                child: BlocBuilder<ShutterBloc, ShutterState>(
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

                              if (post.tags.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '태그된 제품',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: post.tags.map((productId) {
                                          return TaggedProductWidget(
                                            productId: productId,
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),

                              SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaggedProductWidget extends StatelessWidget {
  final String productId;

  const TaggedProductWidget({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get(),
      builder: (context, snapshot) {
        String productName = '로딩중...';

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          productName = data?['name'] ?? '제품 없음';
        }

        return GestureDetector(
          onTap: () {
            context.push('/product-detail', extra: productId);
          },
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.4),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFC9C138).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFC9C138).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_offer,
                  size: 16,
                  color: Color(0xFFC9C138),
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    productName,
                    style: TextStyle(
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
