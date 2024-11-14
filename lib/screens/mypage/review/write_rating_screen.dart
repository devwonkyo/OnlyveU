import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/product/productdetail_bloc.dart';

class WriteRatingScreen extends StatefulWidget {
  final String productId;

  const WriteRatingScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<WriteRatingScreen> createState() => _WriteRatingScreenState();
}

class _WriteRatingScreenState extends State<WriteRatingScreen> {
  double rating = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductDetailBloc>().add(LoadProductDetail(widget.productId));
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
      body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          if(state is ProductDetailLoaded){
            return SingleChildScrollView(
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
                        state.product.productImageList[0],
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // 브랜드명
                    Text(
                      state.product.brandName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // 상품명
                    Text(
                      state.product.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 60.h),
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
                                    'productModel': state.product,
                                    'rating': rating,
                                    'writeUserId': state.userId
                                  });
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Icon(
                              index < rating ? Icons.star : Icons.star,
                              size: 48.sp,
                              color: index < rating ? Colors.amber : Colors.grey[300],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          }

          if(state is ProductDetailLoading){
            return CircularProgressIndicator();
          }

          return const Center(child: Text("no data"));

        },
      ),
    );
  }
}