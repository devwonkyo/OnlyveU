import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/search/tag_search/tag_search_cubit.dart';
import 'package:onlyveyou/screens/search/widgets/show_tags.dart';

import 'widgets/search_main.dart';
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
            preferredSize: const Size.fromHeight(40.0), // 검색창의 높이 설정
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.grey[200]!, width: 1), // 탭 바 하단의 구분선
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SearchTextField(
                  controller: _messageController,
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              context.watch<TagSearchCubit>().state.searchTerm.isEmpty
                  ? SearchMain()
                  : ShowTags(),
            ],
          ),
        ),
      ),
    );
  }
}

/*
할일
- search_text_field의 x와 돋보기 아이콘 간격 줄이기 (뭘해도안됌);
- 검색어 입력 후 x 누르면 다시 main으로 안감;
 */
