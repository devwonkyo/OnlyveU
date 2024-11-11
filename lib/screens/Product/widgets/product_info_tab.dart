import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductInfoTab extends StatefulWidget {
  final List<String> images;

  const ProductInfoTab({Key? key, required this.images}) : super(key: key);

  @override
  _ProductInfoTabState createState() => _ProductInfoTabState();
}

class _ProductInfoTabState extends State<ProductInfoTab> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final displayImages = isExpanded
        ? widget.images
        : widget.images.take(2).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // 이미지 리스트
          ...displayImages.map((imageUrl) => Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 8.h),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          )).toList(),

          // 펼치기/접기 버튼
          if (widget.images.length > 2)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.black),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? '상품정보 접기' : '상품정보 더 보기',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}