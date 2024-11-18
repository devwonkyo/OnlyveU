import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlyveyou/blocs/review/review_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/available_review_model.dart';
import 'package:onlyveyou/models/review_model.dart';

class ModifyReviewScreen extends StatefulWidget {
  final ReviewModel reviewModel;

  const ModifyReviewScreen({Key? key, required this.reviewModel})
      : super(key: key);

  @override
  State<ModifyReviewScreen> createState() => _ReviewCreateScreenState();
}

class _ReviewCreateScreenState extends State<ModifyReviewScreen> {
  late double rating;
  late final TextEditingController _reviewController;
  late final ReviewModel reviewModel;
  late final List<String?> selectedImages;


  @override
  void initState() {
    super.initState();
    reviewModel = widget.reviewModel;
    _reviewController = TextEditingController(text: reviewModel.content);
    rating = reviewModel.rating;
    final List<String> existingImageList = reviewModel.imageUrls;
    selectedImages = List.generate(4, (index) => index < existingImageList.length ? existingImageList[index] : null);
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
          '리뷰 수정',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is SuccessUpdateReview) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
            context.pop();
          }
          if (state is ErrorUpdateReview) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LoadingUpdateReview) {
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
                            image: NetworkImage(reviewModel.productImage),
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
                              "[주문 상품]",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              reviewModel.productName,
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
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          rating = index + 1;
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
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: TextField(
                    controller: _reviewController,
                    maxLines: 8,
                    decoration: InputDecoration(
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
                                    image: hasImage
                                        ? DecorationImage(
                                      image: selectedImages[index]!.startsWith('https')
                                          ? NetworkImage(selectedImages[index]!)
                                          : FileImage(File(selectedImages[index]!)) as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                        : null,
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
                    : Text('리뷰 수정하기'),
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
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          selectedImages[index] = image.path;

          for (int i = 0; i <= 3 && i < selectedImages.length; i++) {
            print(selectedImages[i]);
          }
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
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 내용을 입력해주세요.')),
      );
      return;
    }

    final reviewModel = widget.reviewModel.copyWith(
        rating: rating,
        content: _reviewController.text,
    );

    print('리뷰 업데이트 눌림');

    context.read<ReviewBloc>().add(
      UpdateReviewEvent(reviewModel, selectedImages),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}