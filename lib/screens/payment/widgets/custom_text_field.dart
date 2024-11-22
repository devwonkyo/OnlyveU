import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/theme/theme_bloc.dart';
import 'package:onlyveyou/blocs/theme/theme_state.dart';
import 'package:onlyveyou/utils/styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final int maxLength;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.maxLength = 100,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state is ThemeDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
