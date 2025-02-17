import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/ai_recommend_bloc.dart';
import 'package:onlyveyou/screens/home/ai_recommend/widgets/ai_recommend_empty_state.dart';
import 'package:onlyveyou/utils/format_price.dart';

class AIRecommendScreen extends StatefulWidget {
  const AIRecommendScreen({super.key});

  @override
  State<AIRecommendScreen> createState() => _AIRecommendScreenState();
}

class _AIRecommendScreenState extends State<AIRecommendScreen> {
  final ScrollController _scrollController = ScrollController();
  late AIRecommendBloc _aiRecommendBloc;

  @override
  void initState() {
    super.initState();
    _aiRecommendBloc = context.read<AIRecommendBloc>();
    // 활동 데이터는 자동으로 구독되고 있으므로 추가 작업 불필요
  }
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _aiRecommendBloc = context.read<AIRecommendBloc>();
  //     // 초기 데이터 로드
  //     //_aiRecommendBloc.add(const LoadAIRecommendations());
  //   });
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AI 추천 헤더 섹션
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A11CB),
                Color(0xFF2575FC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '맞춤 AI 추천',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '회원님의 취향을 분석한\n맞춤 상품',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<AIRecommendBloc>()
                          .add(const LoadAIRecommendations());
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: const Color(0xFF2575FC),
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'AI 추천받기',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF2575FC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // AI 분석 요약 카드들 - BlocBuilder로 실시간 데이터 표시
              BlocBuilder<AIRecommendBloc, AIRecommendState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAnalysisCard(
                          icon: Icons.remove_red_eye,
                          title: '최근 본 상품',
                          value: '${state.activityCounts['viewCount']}개',
                        ),
                        SizedBox(width: 12.w),
                        _buildAnalysisCard(
                          icon: Icons.favorite,
                          title: '관심 상품',
                          value: '${state.activityCounts['likeCount']}개',
                        ),
                        SizedBox(width: 12.w),
                        _buildAnalysisCard(
                          icon: Icons.shopping_cart,
                          title: '장바구니',
                          value: '${state.activityCounts['cartCount']}개',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // 추천 상품 리스트
        Expanded(
          child: BlocBuilder<AIRecommendBloc, AIRecommendState>(
              builder: (context, state) {
            if (state is AIRecommendLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text(
                      'AI가 맞춤 상품을 분석중입니다...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AIRecommendLoaded) {
              return ListView.builder(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                itemCount: min(state.products.length, 10),
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return GestureDetector(
                    onTap: () => context.push('/product-detail',
                        extra: product.productId),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.w),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상품 이미지
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: product.productImageList.isNotEmpty
                                    ? Image.network(
                                        product.productImageList.first,
                                        width: 120.w,
                                        height: 120.w,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 120.w,
                                          height: 120.w,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 40.w,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 120.w,
                                        height: 120.w,
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 40.w,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                              ),
                              // AI 추천 뱃지
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 12.sp,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'AI Pick',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16.w),
                          // 상품 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${formatPrice(product.price)}원',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Text(
                                      '${product.discountPercent}%',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '${formatDiscountedPriceToString(product.price, product.discountPercent.toDouble())}원',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                // AI 추천 이유 태그
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: BlocBuilder<AIRecommendBloc,
                                      AIRecommendState>(
                                    builder: (context, state) {
                                      if (state is AIRecommendLoaded) {
                                        return Text(
                                          state.getRecommendReason(
                                              product.productId),
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.blue[700],
                                          ),
                                        );
                                      }
                                      return Text(
                                        '회원님 취향과 일치',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.blue[700],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 좋아요 및 장바구니 아이콘
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is AIRecommendError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              );
            } else {
              return const AIRecommendEmptyState();
            }
            return Container();
          }),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateDiscountedPrice(String originalPrice, int discountPercent) {
    final price = int.parse(originalPrice.replaceAll(',', ''));
    final discountedPrice = price - (price * (discountPercent / 100)).round();
    return discountedPrice.toString();
  }
}
