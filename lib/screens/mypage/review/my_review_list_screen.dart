// my_review_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/review/review_bloc.dart';
import 'package:onlyveyou/screens/mypage/review/widgets/review_item.dart';

class MyReviewListScreen extends StatelessWidget {
  const MyReviewListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        if (state is LoadingMyReview) {
          // 로딩 상태
          return const Center(child: CircularProgressIndicator());
        } else if (state is LoadErrorMyReview) {
          // 에러 상태
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          );
        } else if (state is LoadedMyReview) {
          final reviewList = state.reviewList;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  '리뷰 정책 위반으로 블라인드된 리뷰는 상품 상세페이지 리뷰목록에 노출되지 않습니다. 블라인드 리뷰 운영 정책을 확인해주세요.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Text(
                      '누적 리뷰 건 수 ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${reviewList.length}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      ' 건',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              if (reviewList.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 32.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          '아직 작성한 리뷰가 없어요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: reviewList.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey[300]),
                    itemBuilder: (context, index) => ReviewItem(
                      reviewModel: reviewList[index],
                    ),
                  ),
                ),
            ],
          );
        }

        // 기본 상태 (이론적으로 사용되지 않음)
        return const SizedBox.shrink();
      },
    );
  }
}