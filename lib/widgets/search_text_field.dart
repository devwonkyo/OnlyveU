import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    required this.controller,
    required this.onPressed,
  });
  final TextEditingController controller;
  final void Function() onPressed;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // 원하는 너비 설정
      height: 38.0, // 원하는 높이 설정
      child: TextField(
        maxLines: 1,
        controller: widget.controller,
        onChanged: (value) => setState(() {}),
        // 입력창
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          hintText: '상품, 브랜드, 성분 검색',
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.transparent, // 테두리 색상을 투명하게 설정
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.transparent, // 테두리 색상을 투명하게 설정
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          // 보내기 버튼
          suffixIcon: Visibility(
            visible: widget.controller.text.isNotEmpty,
            child: IconButton(
              onPressed: widget.onPressed,
              icon: const Icon(
                Icons.search_sharp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
