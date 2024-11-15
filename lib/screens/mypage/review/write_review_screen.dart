import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlyveyou/blocs/review/review_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/models/review_model.dart';

class WriteReviewScreen extends StatefulWidget {
  final ProductModel productModel;
  final DateTime purchaseDate;
  final double rating;
  final String writeUserId;
  final OrderType orderType;


  const WriteReviewScreen({Key? key, required this.productModel, required this.rating, required this.writeUserId, required this.purchaseDate, required this.orderType})
      : super(key: key);

  @override
  State<WriteReviewScreen> createState() => _ReviewCreateScreenState();
}

class _ReviewCreateScreenState extends State<WriteReviewScreen> {
  late double rating;
  final TextEditingController _reviewController = TextEditingController();
  late final ProductModel productModel;
  final List<File?> selectedImages = List.generate(4, (index) => null);
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    rating = widget.rating;
    productModel = widget.productModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '리뷰 작성',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is SuccessAddReview) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
            context.pop();
          }
          if (state is ErrorAddReview) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LoadingAddReview) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Row(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(productModel.productImageList[0]),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productModel.brandName,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              productModel.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(height: 8.h, color: Colors.grey[200]),
                SizedBox(height: 20.h),
                Center(
                  child: Text("💬  상품은 어떠셨나요?",style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Icon(
                        index < rating ? Icons.star : Icons.star,
                        size: 36.sp,
                        color: index < rating ? Colors.amber : Colors.grey[300],
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: TextField(
                    controller: _reviewController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: '상품에 대한 솔직한 리뷰를 남겨주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppsColor.pastelGreen),
                      ),
                      contentPadding: EdgeInsets.all(16.w),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(height: 8.h, color: Colors.grey[200]),
                SizedBox(height: 20.h),
                Center(
                  child: Text("📷 포토",style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          final hasImage = selectedImages[index] != null;

                          return GestureDetector(
                            onTap: () => _pickImage(index),
                            child: Stack(
                              children: [
                                Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8.r),
                                    image: hasImage ? DecorationImage(
                                      image: FileImage(selectedImages[index]!),
                                      fit: BoxFit.cover,
                                    ) : null,
                                  ),
                                  child: !hasImage ? Center(
                                    child: Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 32.sp,
                                      color: Colors.grey[400],
                                    ),
                                  ) : null,
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        '사진은 PNG, GIF, JPG 파일만 등록 가능합니다.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: ElevatedButton(
                onPressed: state is LoadingAddReview ? null : _submitReview,
                child: state is LoadingAddReview
                    ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text('리뷰 등록하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppsColor.pastelGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        setState(() {
          selectedImages[index] = file;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다.')),
      );
    }
  }

  void _submitReview() {
    // TODO: 리뷰 등록 로직 구현
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 내용을 입력해주세요.')),
      );
      print('업로드 못함 리뷰내용 입력해');
      return;
    }

    final reviewModel = ReviewModel(reviewId: "",
        productId: productModel.productId,
        productImage: productModel.productImageList[0],
        productName: productModel.name,
        userId: widget.writeUserId,
        purchaseDate: widget.purchaseDate,
        userName: "",
        orderType: widget.orderType,
        rating: rating, content: _reviewController.text, createdAt: DateTime.now());

    print('업로드 눌림');
    context.read<ReviewBloc>().add(
      AddReviewEvent(reviewModel,selectedImages),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}