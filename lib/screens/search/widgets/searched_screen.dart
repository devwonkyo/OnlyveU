import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchedScreen extends StatelessWidget {
  const SearchedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (bool? checked) {},
            ),
            Text(
              '오늘드림',
              style: TextStyle(fontSize: 15.sp),
            ),
            Checkbox(
              value: false,
              onChanged: (bool? checked) {},
            ),
            Text(
              '픽업',
              style: TextStyle(fontSize: 15.sp),
            ),
          ],
        )
      ],
    );
  }
}
