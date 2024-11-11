import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/widgets/default_appbar.dart';
import 'package:onlyveyou/blocs/shutter/shutter_bloc.dart';
import 'package:onlyveyou/blocs/shutter/shutter_event.dart';
import 'package:onlyveyou/blocs/shutter/shutter_state.dart';
import 'package:onlyveyou/screens/shutter/shutter_post.dart';
import 'package:onlyveyou/screens/shutter/firestore_service.dart';
import 'package:onlyveyou/models/post_model.dart';

// shutter_screen.dart
class ShutterScreen extends StatelessWidget {
  const ShutterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShutterBloc(FirestoreService())
        ..add(FetchPosts()), // Trigger FetchPosts event here
      child: Scaffold(
        appBar: DefaultAppBar(mainColor: const Color(0xFFC9C138)),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Existing UI: header and tag buttons
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
                // Fetch and display posts
                BlocBuilder<ShutterBloc, ShutterState>(
                  builder: (context, state) {
                    if (state.posts.isEmpty) {
                      return const Center(child: Text('No posts available.'));
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: state.posts.length,
                      itemBuilder: (context, index) {
                        final post = state.posts[index];
                        return _buildPostFromModel(post);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to display the post from the model
  Widget _buildPostFromModel(PostModel post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Displaying images if available
          if (post.imageUrls.isNotEmpty)
            Image.network(
                post.imageUrls[0]), // You can use a list of images if needed
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User information (for now, username is static)
                const Text(
                  'username', // Use dynamic username from Firebase if available
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(post.text),
                const SizedBox(height: 10),
                // Displaying tags
                if (post.tags.isNotEmpty)
                  Row(
                    children: post.tags
                        .map((tag) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(label: Text(tag)),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // shutter_screen.dart의 하단에 추가

  Widget _buildTagButton(
      BuildContext context, String tag, String? selectedTag) {
    final isSelected = tag == selectedTag;

    return GestureDetector(
      onTap: () {
        context.read<ShutterBloc>().add(TagSelected(tag));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
