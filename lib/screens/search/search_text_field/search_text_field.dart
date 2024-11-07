import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'bloc/search_text_field_bloc.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: BlocListener<SearchTextFieldBloc, SearchTextFieldState>(
        listener: (context, state) {
          if (state is SearchTextFieldSubmitted) {
            _controller.text = state.text;
          }
        },
        child: TextField(
          controller: _controller,
          onChanged: (text) {
            context.read<SearchTextFieldBloc>().add(TextChanged(text.trim()));
          },
          onSubmitted: (text) {
            context.read<SearchTextFieldBloc>().add(TextSubmitted(text.trim()));
          },
          // 입력창
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEEEEEE),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            hintText: '제품, 성분, 브랜드 검색하기',
            hintStyle: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w400),
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
            suffixIcon: BlocBuilder<SearchTextFieldBloc, SearchTextFieldState>(
                builder: (context, state) {
              print('$state');
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: state is! SearchTextFieldEmpty,
                    child: GestureDetector(
                      onTap: () {
                        _controller.clear();
                        context.read<SearchTextFieldBloc>().add(TextDeleted());
                      },
                      child: SizedBox(
                        width: 40.w,
                        child: Icon(
                          Icons.cancel,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: state is! SearchTextFieldSubmitted,
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        context
                            .read<SearchTextFieldBloc>()
                            .add(TextSubmitted(_controller.text.trim()));
                      },
                      child: SizedBox(
                        width: 40.w,
                        child: const Icon(
                          Icons.search,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
