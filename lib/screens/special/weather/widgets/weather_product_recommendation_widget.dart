import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/special_bloc/weather/weather_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/format_price.dart';

/// 날씨에 기반한 상품 추천 위젯
class WeatherProductRecommendationWidget extends StatelessWidget {
  const WeatherProductRecommendationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // WeatherBloc의 상태를 기반으로 UI를 빌드
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoading) {
          // 날씨 정보 로딩 중일 때 로딩 인디케이터 표시
          return SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is WeatherLoaded) {
          // 날씨 정보가 로드된 경우, 추천 상품 리스트 표시
          return SliverList(
            delegate: SliverChildListDelegate([
              // 추천 섹션 헤더
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 추천 섹션 제목
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '날씨 맞춤 추천',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // 추천 이유 텍스트
                    Text(
                      state.recommendationReason,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // 추천 상품 그리드 뷰
              GridView.builder(
                shrinkWrap: true, // 부모 높이에 맞게 크기 조정
                physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 열 개수
                  mainAxisSpacing: 16.h, // 세로 간격
                  crossAxisSpacing: 16.w, // 가로 간격
                  childAspectRatio: 0.6, // 그리드 셀 비율
                  mainAxisExtent: 280.h, // 셀의 높이
                ),
                // 각 상품 카드 생성
                itemBuilder: (context, index) => _buildRecommendationCard(
                  context,
                  state.recommendedProducts[index],
                ),
                itemCount: state.recommendedProducts.length, // 상품 개수
              ),
            ]),
          );
        }

        // 기본 상태에서는 아무것도 표시하지 않음
        return SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  /// 추천 상품 카드 생성 위젯
  Widget _buildRecommendationCard(BuildContext context, ProductModel product) {
    return GestureDetector(
      // 카드 클릭 시 상품 상세 페이지로 이동
      onTap: () => context.push('/product-detail', extra: product.productId),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 배경색
          borderRadius: BorderRadius.circular(16), // 둥근 테두리
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // 그림자 색상
              blurRadius: 10, // 그림자 블러 정도
              offset: Offset(0, 2), // 그림자 위치
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            // 상품 이미지 섹션
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 150.h, // 이미지 높이
                child: Stack(
                  children: [
                    if (product.productImageList.isNotEmpty)
                      // 상품 이미지 표시
                      Image.network(
                        product.productImageList.first, // 첫 번째 이미지
                        width: double.infinity, // 전체 폭에 맞춤
                        height: 150.h, // 이미지 높이
                        fit: BoxFit.cover, // 이미지 비율 유지
                        errorBuilder: (context, error, stackTrace) => Center(
                          // 이미지 로드 실패 시 아이콘 표시
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 40.sp,
                          ),
                        ),
                      )
                    else
                      // 이미지가 없을 경우 기본 아이콘 표시
                      Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 40.sp,
                        ),
                      ),
                    // '날씨 맞춤' 라벨
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFA41B), Color(0xFFFF7E5F)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF7E5F).withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny_outlined, // 날씨 아이콘
                              color: Colors.white,
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '날씨 맞춤',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 상품 정보 섹션
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상품 이름
                  Text(
                    product.name,
                    style: TextStyle(
                      color: Color(0xFF2D3436),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2, // 최대 2줄
                    overflow: TextOverflow.ellipsis, // 텍스트 오버플로 처리
                  ),
                  SizedBox(height: 4.h),
                  // 가격 정보
                  Row(
                    children: [
                      if (product.discountPercent > 0)
                        // 할인 정보 표시
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF4E3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.discountPercent}%', // 할인율
                            style: TextStyle(
                              color: Color(0xFFFFA41B),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      SizedBox(width: 8.w),
                      // 최종 가격
                      Text(
                        '₩${formatPrice(product.price)}',
                        style: TextStyle(
                          color: Color(0xFF2D3436),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // 상품 평점 및 리뷰 수
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        product.rating.toStringAsFixed(1), // 평점
                        style: TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(${product.reviewList.length})', // 리뷰 개수
                        style: TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
