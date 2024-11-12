import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TreandSearchView extends StatelessWidget {
  const TreandSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190.h,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 5.3,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            child: InkWell(
              onTap: () {
                // 검색 기능 연동
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    // 순위
                    Container(
                      width: 24.w,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: index < 3 ? Colors.red : Colors.black,
                        ),
                      ),
                    ),
                    // 검색어
                    Expanded(
                      child: Text(
                        '인기 검색어 ${index + 1}',
                        style: TextStyle(
                          fontSize: 13.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 변동
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_drop_up_rounded,
                          color: Colors.red,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
