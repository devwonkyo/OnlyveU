import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArFilterPreview extends StatelessWidget {
  final List<String> filters;
  final int selectedIndex;
  final Function(int) onFilterSelected;

  const ArFilterPreview({
    Key? key,
    required this.filters,
    required this.selectedIndex,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final index = entry.key;
          final filter = entry.value;
          return GestureDetector(
            onTap: () => onFilterSelected(index),
            child: Container(
              width: 30.w,
              height: 30.w,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: index == selectedIndex
                      ? Colors.white
                      : Colors.transparent,
                  width: 2.w,
                ),
                image: DecorationImage(
                  image: AssetImage(filter),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
