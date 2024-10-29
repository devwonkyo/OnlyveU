import 'package:flutter/material.dart';

import '../../widgets/search_text_field.dart';

class SearchScreen extends StatefulWidget {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // 검색창의 높이 설정
          child: Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
            child: Expanded(
              child: SearchTextField(
                controller: _messageController,
                onPressed: () => _sendMessage(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
