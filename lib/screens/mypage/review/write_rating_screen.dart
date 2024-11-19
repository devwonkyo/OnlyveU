import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/product/productdetail_bloc.dart';
import 'package:onlyveyou/models/available_review_model.dart';
import 'package:onlyveyou/models/order_model.dart';

class WriteRatingScreen extends StatefulWidget {
  final AvailableOrderModel availableOrderModel;

  const WriteRatingScreen({
    super.key, required this.availableOrderModel,
  });

  @override
  State<WriteRatingScreen> createState() => _WriteRatingScreenState();
}

class _WriteRatingScreenState extends State<WriteRatingScreen> {
  double rating = 0;
  late AvailableOrderModel availableOrderModel;

  @override
  void initState() {
    super.initState();
    availableOrderModel = widget.availableOrderModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '리뷰 작성',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey[300]),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              // 상품 이미지
              Container(
                width: 200.w,
                height: 200.w,
                child: Image.network(
                  availableOrderModel.orderItem.productImageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 40.h),
              // 상품명
              Text(
                availableOrderModel.orderItem.productName,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              // 별점 섹션
              Text(
                '상품은 어떠셨나요?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20.h),
              // 별점
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = index + 1;
                      });
                      Future.delayed(Duration(milliseconds: 500), () {
                        context.push("/write_review",
                            extra: {
                              'rating': rating,
                              'availableOrderModel': widget.availableOrderModel
                            });
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Icon(
                        index < rating ? Icons.star : Icons.star,
                        size: 36.sp,
                        color: index < rating ? Colors.amber : Colors.grey[300],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      )
    );
  }
}