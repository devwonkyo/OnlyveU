import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/models/product_model.dart'; // 수정된 부분: ProductModel 임포트
import 'package:onlyveyou/utils/styles.dart';

// 추천 상품 목록을 보여주는 위젯
class RecommendedProductsWidget extends StatelessWidget {
  final List<ProductModel> recommendedProducts; // 수정된 부분: 타입 변경
  final bool isPortrait;
  final String userId; // 추가된 부분: userId를 전달

  RecommendedProductsWidget({
    required this.recommendedProducts,
    required this.isPortrait,
    required this.userId, // 추가된 부분: userId 필드 추가
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 추천 상품 섹션 제목과 더보기 버튼
        Padding(
          padding: AppStyles.defaultPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('국한님을 위한 추천상품', style: AppStyles.headingStyle),
              GestureDetector(
                onTap: () => context.push('/more-recommended'),
                child: Text(
                  '더보기 >',
                  style: AppStyles.bodyTextStyle
                      .copyWith(color: AppStyles.greyColor),
                ),
              )
            ],
          ),
        ),
        // 추천 상품 리스트뷰
        SizedBox(
          height: isPortrait ? 340 : 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedProducts.length,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) => _buildProductCard(context, index),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    final item = recommendedProducts[index];
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 상품 이미지
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.productImageList.isNotEmpty
                  ? Image.network(
                      item.productImageList.first,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Icon(Icons.error));
                      },
                    )
                  : Image.asset(
                      'assets/default_image.png', // 기본 로컬 이미지
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          SizedBox(height: 8),

          // 2. 상품명
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),

          // 3. 가격 정보
          if (item.discountPercent > 0)
            Text(
              '${item.price}원',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          SizedBox(height: 2),
          Row(
            children: [
              if (item.discountPercent > 0)
                Text(
                  '${item.discountPercent}%',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              SizedBox(width: 4),
              Text(
                '${item.discountedPrice}원',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),

          // 4. 태그들
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '오늘드림',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 4),
              if (item.isBest)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BEST',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6),

          // 5. 별점과 리뷰 수
          Row(
            children: [
              Icon(
                Icons.star,
                size: 12,
                color: AppStyles.mainColor,
              ),
              SizedBox(width: 2),
              Text(
                item.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 2),
              Text(
                '(${item.reviewCount})',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),

          // 6. 좋아요와 장바구니 버튼
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  context
                      .read<HomeBloc>()
                      .add(ToggleProductFavorite(item, userId)); // userId 전달
                },
                child: Container(
                  width: 20,
                  height: 20,
                  child: Icon(
                    item.isFavorite(userId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 18,
                    color: item.isFavorite(userId) ? Colors.red : Colors.grey,
                  ),
                ),
              ),
              SizedBox(width: 25),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 22,
                  height: 22,
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
