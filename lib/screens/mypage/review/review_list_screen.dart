import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/review/review_bloc.dart';
import 'package:onlyveyou/core/router.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/screens/mypage/review/my_review_list_screen.dart';
import 'package:onlyveyou/screens/mypage/review/write_rating_screen.dart';
import 'package:onlyveyou/screens/mypage/review/write_review_list_screen.dart';

class ReviewListScreen extends StatelessWidget {
  final String productId;

  const ReviewListScreen({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_bag_outlined, color: Colors.black),
              onPressed: () {
                // TODO: 장바구니 페이지로 이동
                context.push("/write_rating",extra: {
                  "productId" : productId,
                  "purchaseDate" : DateTime.now(),
                  "orderType" : OrderType.delivery
                });
              },
            ),
          ],
          title: Text(
            '리뷰',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  indicatorWeight: 2,
                  labelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: (index) {
                    // 탭 인덱스에 따른 처리
                    switch (index) {
                      case 0:
                        print('리뷰 작성 탭 클릭');
                        // TODO: 리뷰 작성 탭 클릭 시 처리할 로직
                        break;
                      case 1:
                        print('나의 리뷰 탭 클릭');
                        context.read<ReviewBloc>().add(LoadReviewListWithUserIdEvent());
                        break;
                    }
                  },
                  tabs: [
                    Tab(text: '리뷰 작성'),
                    Tab(text: '나의 리뷰'),
                  ],
                ),
                // Divider(height: 1, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            WriteReviewListScreen(),
            MyReviewListScreen(),
          ],
        ),
      ),
    );
  }
}