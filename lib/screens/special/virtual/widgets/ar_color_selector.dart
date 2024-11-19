import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArColorSelector extends StatelessWidget {
  final List<Color> colors;
  final int selectedIndex;
  final Function(int) onColorSelected;

  const ArColorSelector({
    Key? key,
    required this.colors,
    required this.selectedIndex,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: colors.asMap().entries.map((entry) {
          final index = entry.key;
          final color = entry.value;
          return GestureDetector(
            onTap: () => onColorSelected(index),
            child: Container(
              width: 30.w,
              height: 30.w,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedIndex == index
                      ? Colors.white
                      : Colors.transparent,
                  width: 2.w,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
