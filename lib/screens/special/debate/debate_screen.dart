import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';

import '../../../blocs/home/home_bloc.dart';
import '../../../models/product_model.dart';
import 'bloc/chat_bloc.dart';

class DebateScreen extends StatelessWidget {
  const DebateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('VS 투표', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildVoteBar(),
            _buildProductComparison(),
            FloatingActionButton.extended(
              onPressed: () {
                // Show voting dialog
              },
              label: const Text('투표하기'),
              icon: const Icon(Icons.how_to_vote),
              backgroundColor: Colors.blue,
            ),
            Expanded(child: _buildChatSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteBar() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 65, // Left product percentage
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade300],
                ),
              ),
              child: const Center(
                child: Text(
                  '65%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 35, // Right product percentage
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [Colors.red.shade300, Colors.red.shade400],
                ),
              ),
              child: const Center(
                child: Text(
                  '35%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductComparison() {
    return BlocSelector<HomeBloc, HomeState, List<ProductModel>>(
      selector: (state) => state is HomeLoaded ? state.popularProducts : [],
      builder: (context, products) {
        return Container(
          height: 205.h, // Reduced from 280.h
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                  child: _buildProductCard(
                      context: context, isLeft: true, product: products.first)),
              SizedBox(
                width: 30.w, // Reduced from 40.w
                child: Center(
                  child: Container(
                    width: 30.w, // Reduced from 40.w
                    height: 30.w, // Reduced from 40.w
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp, // Reduced from 16.sp
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: _buildProductCard(
                      context: context, isLeft: false, product: products.last)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
      {required BuildContext context,
      required bool isLeft,
      required ProductModel product}) {
    // 가격 포맷팅 메서드 추가
    String formatPrice(String price) {
      try {
        return price.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      } catch (e) {
        return '0';
      }
    }

    return GestureDetector(
      onTap: () {
        context.push("/product-detail", extra: product.productId);
      },
      child: Card(
        elevation: 2, // Reduced from 4
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Container(
                height: 120.h, // Reduced from 160.h
                color: Colors.grey.shade100,
                child: Image.network(
                  product.productImageList.first,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w), // Reduced from 12.w
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14.sp, // Reduced from 16.sp
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1, // Reduced from 2
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h), // Reduced from 4.h
                  Row(
                    children: [
                      Text(
                        '${product.discountPercent}%',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.sp, // Reduced from 14.sp
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w), // Reduced from 8.w
                      Text(
                        '₩${formatPrice(product.discountedPrice.toString())}',
                        style: TextStyle(
                          fontSize: 12.sp, // Reduced from 14.sp
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₩${formatPrice(product.price)}',
                    style: TextStyle(
                      fontSize: 10.sp, // Reduced from 12.sp
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
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

  Widget _buildChatSection() {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                reverse: true, // 새 메시지가 아래에서 위로 쌓임
                itemCount: 20,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16.r,
                          backgroundColor: Colors.grey.shade300,
                          child: Text('U${index + 1}'),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              '채팅 메시지 ${index + 1}',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
