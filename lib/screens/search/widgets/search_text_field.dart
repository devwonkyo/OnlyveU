import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/search/search/search_bloc.dart';

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
      height: 40.h, // 원하는 높이 설정
      child: TextField(
        minLines: 1,
        maxLines: 1,
        controller: widget.controller,
        onChanged: (newSearchTerm) {
          setState(() {});
          context.read<SearchBloc>().add(TextChangedEvent(text: newSearchTerm));
        },
        // 입력창
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          hintText: '상품, 브랜드, 성분 검색',
          hintStyle:
              const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(25.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(25.r),
          ),
          // 보내기 버튼
          suffixIcon: Container(
            width: 70.w,
            // color: Colors.red,
            padding: EdgeInsets.only(right: 12.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: widget.controller.text.isNotEmpty,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {});
                      widget.controller.text = '';
                      context
                          .read<SearchBloc>()
                          .add(const TextChangedEvent(text: ''));
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onPressed,
                  child: const Icon(
                    Icons.search,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
