import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SearchTextFieldStatus {
  empty,
  typing,
  submitted,
}

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    this.onSubmitted,
    this.hintText,
  });
  final void Function(String)? onSubmitted;
  final String? hintText;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _controller;
  SearchTextFieldStatus _state = SearchTextFieldStatus.empty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_state != SearchTextFieldStatus.typing && _controller.text.isNotEmpty) {
      return setState(() {
        _state = SearchTextFieldStatus.typing;
      });
    } else if (_state == SearchTextFieldStatus.submitted &&
        _controller.text.isEmpty) {
      return setState(() {
        _state = SearchTextFieldStatus.empty;
      });
    }
  }

  void _onSubmitted(String? text) {
    if (text == null) {
      text = _controller.text;
    } else {
      _controller.text = text;
    }
    setState(() {
      _state = SearchTextFieldStatus.submitted;
    });
    FocusScope.of(context).unfocus();
  }

  void _onDelete() {
    setState(() {
      _controller.clear();
      _state = SearchTextFieldStatus.empty;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_controller.text);
    print(_state);
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: TextField(
        minLines: 1,
        maxLines: 1,
        controller: _controller,
        onSubmitted: _onSubmitted,
        // 입력창
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          hintText: widget.hintText,
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: _state != SearchTextFieldStatus.empty,
                child: GestureDetector(
                  onTap: _onDelete,
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
                visible: _state != SearchTextFieldStatus.submitted,
                child: GestureDetector(
                  onTap: () {
                    _onSubmitted('helloWWWW');
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
          ),
        ),
      ),
    );
  }
}
