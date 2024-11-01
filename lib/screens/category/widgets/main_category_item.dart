import 'package:flutter/material.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/category_model.dart';

class MainCategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const
  MainCategoryItem({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        color: isSelected ? Colors.white : Colors.grey[100],
        child: Text(
          category.name,
          style: TextStyle(
            color: isSelected ? AppsColor.pastelGreen : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}