import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final int maxLength;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.maxLength = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppStyles.headingStyle,
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
