import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArFilterModal extends StatelessWidget {
  final String categoryName;
  final List<String> filters;
  final Function(int) onFilterSelected;

  const ArFilterModal({
    Key? key,
    required this.categoryName,
    required this.filters,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$categoryName 필터 선택',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
                childAspectRatio: 0.8,
              ),
              itemCount: filters.length,
              itemBuilder: (context, index) => _buildFilterItem(
                context,
                filters[index],
                index,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(BuildContext context, String imageAsset, int index) {
    return GestureDetector(
      onTap: () {
        onFilterSelected(index);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  image: DecorationImage(
                    image: AssetImage(imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFilterDescription(index),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$categoryName 메이크업',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterDescription(int index) {
    switch (categoryName) {
      case '립 메이크업':
        return '립스틱 필터 ${index + 1}';
      case '블러셔':
        return '블러셔 필터 ${index + 1}';
      case '마스카라':
        return '마스카라 필터 ${index + 1}';
      default:
        return '필터 ${index + 1}';
    }
  }
}
