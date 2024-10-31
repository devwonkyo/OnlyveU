import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/search/tag_search/tag_search_cubit.dart';

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
  void dispose() {
    widget.controller.clear();
    widget.controller.dispose();
    super.dispose();
  }

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
          context.read<TagSearchCubit>().setSearchTerm(newSearchTerm);
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
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: widget.controller.text.isNotEmpty,
                child: IconButton(
                  onPressed: () {
                    widget.controller.clear();
                    context.read<TagSearchCubit>().setSearchTerm('');
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onPressed,
                icon: const Icon(
                  Icons.search,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
