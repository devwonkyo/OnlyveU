import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpansionTileWidget extends StatelessWidget {
  final List<Map<String, String>> items = [
    {
      'title': '배송안내',
      'content': 'assets/image/product/info1.jpeg',
    },
    {
      'title': '교환/반품 불가안내',
      'content': 'assets/image/product/info2.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0.w),
      child: Column(
        children: [
          for (var item in items)
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16.0.w,vertical: 8.0.h),
              child: ExpansionTile(
                title: Text(
                  item['title']!,
                  style: TextStyle(
                    fontSize: 16.0.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                  side: BorderSide.none,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.0.w),
                    child: Image.asset(
                      item['content']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
