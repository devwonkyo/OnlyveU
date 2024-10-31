import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/search/tag_search/tag_search_cubit.dart';

class SearchTextField extends StatelessWidget {
  SearchTextField({
    super.key,
    required this.controller,
    required this.onPressed,
  });
  final TextEditingController controller;
  final void Function() onPressed;

  final debounce = Debounce(milliseconds: 50);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // 원하는 너비 설정
      height: 38.h, // 원하는 높이 설정
      child: TextField(
        minLines: 1,
        maxLines: 1,
        controller: controller,
        onChanged: (String? newSearchTerm) {
          if (newSearchTerm != null) {
            debounce.run(() {
              context.read<TagSearchCubit>().setSearchTerm(newSearchTerm);
            });
          }
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
                visible: controller.text.isNotEmpty,
                child: IconButton(
                  onPressed: () {
                    controller.clear();
                    context.read<TagSearchCubit>().setSearchTerm('');
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              IconButton(
                onPressed: onPressed,
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

class Debounce {
  final int milliseconds;
  Debounce({
    required this.milliseconds,
  });

  Timer? _timer;

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
