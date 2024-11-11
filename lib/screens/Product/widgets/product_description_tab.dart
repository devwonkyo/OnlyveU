// 탭 컨텐츠 위젯들
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/models/product_model.dart';

class ProductDescriptionTab extends StatefulWidget {
  final ProductModel product;

  const ProductDescriptionTab({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDescriptionTab> createState() => _ProductDescriptionTabState();
}

class _ProductDescriptionTabState extends State<ProductDescriptionTab> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (!isExpanded) ...[
            // 첫 번째 이미지
            Image.network(
              widget.product.descriptionImageList[0],
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // 두 번째 이미지와 그라데이션 오버레이
            Stack(
              children: [
                Image.network(
                  widget.product.descriptionImageList[1],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 150.h, // 그라데이션 높이
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
                // 더보기 버튼
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20.h,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey,
                          minimumSize: Size(double.infinity, 48.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),

                            side: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Row의 크기를 내용물에 맞게 조절
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '상품정보 더 보기',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.keyboard_arrow_down,  // 또는 Icons.expand_more
                              size: 18.sp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // 모든 이미지 표시
            ...widget.product.descriptionImageList.map((url) {
              return Image.network(
                url,
                width: double.infinity,
                fit: BoxFit.cover,
              );
            }).toList(),
            // 접기 버튼
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isExpanded = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    side: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '상품정보 접기',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_up,  // 또는 Icons.expand_less
                      size: 18.sp,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}