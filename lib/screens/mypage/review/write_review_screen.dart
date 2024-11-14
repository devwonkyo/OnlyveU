import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/review/review_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/models/review_model.dart';

class WriteReviewScreen extends StatefulWidget {
  final ProductModel productModel;
  final double rating;
  final String writeUserId;


  const WriteReviewScreen({Key? key, required this.productModel, required this.rating, required this.writeUserId})
      : super(key: key);

  @override
  State<WriteReviewScreen> createState() => _ReviewCreateScreenState();
}

class _ReviewCreateScreenState extends State<WriteReviewScreen> {
  late double rating;
  final TextEditingController _reviewController = TextEditingController();
  late final ProductModel productModel;

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
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              productModel.name,
                              style: TextStyle(
                                fontSize: 16.sp,
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
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(
                          index < rating ? Icons.star : Icons.star,
                          size: 48.sp,
                          color: index < rating ? Colors.amber : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 32.h),
                  TextField(
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
                ],
              ),
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
        userId: widget.writeUserId,
        userName: "",
        rating: rating, content: _reviewController.text, createdAt: DateTime.now());

    print('업로드 눌림');
    context.read<ReviewBloc>().add(
      AddReviewEvent(reviewModel),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}