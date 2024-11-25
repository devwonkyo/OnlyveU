import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/config/color.dart';

class SubCategoryHeader extends StatelessWidget {
  final String icon;
  final String title;
  final bool hasArrow;

  const SubCategoryHeader({
    required this.icon,
    required this.title,
    this.hasArrow = false,
  });

  IconData _getIconData(String iconName) {
    // iconName에 따라 IconData 반환
    switch (iconName) {
      case 'skin':
        return Icons.spa;
      case 'makeup':
        return Icons.brush;
      case 'mask':
        return Icons.masks;
      case 'cleanging':
        return Icons.cloud;
      case 'beauty':
        return Icons.shopping_bag;
      case 'man':
        return Icons.male;
      case 'hair':
        return Icons.content_cut;
      case 'body':
        return Icons.sanitizer;
      case 'suncare':
        return Icons.wb_sunny;
      default:
        return Icons.help_outline; // 기본값
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppsColor.pastelGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child:Icon(
              _getIconData(icon), // 문자열을 IconData로 변환해서 사용
              size: 20.sp,
              color: AppsColor.pastelGreen,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasArrow) ...[
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey,
            ),
          ],
        ],
      ),
    );
  }
}