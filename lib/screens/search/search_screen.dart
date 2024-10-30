import 'package:flutter/material.dart';

import 'widgets/before_search_widgets.dart';
import 'widgets/search_text_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    FocusScope.of(context).unfocus();

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.shopping_bag_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0), // 검색창의 높이 설정
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchTextField(
                controller: _messageController,
                onPressed: () => _sendMessage(),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 10, left: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                BeforeSearchWidgets(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
