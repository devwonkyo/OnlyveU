import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/styles.dart';

// 추천 상품 목록을 보여주는 위젯
class RecommendedProductsWidget extends StatelessWidget {
  final List<String> recommendedProducts; // 추천 상품 이미지 경로 리스트
  final bool isPortrait; // 세로 모드 여부

  RecommendedProductsWidget({
    required this.recommendedProducts,
    required this.isPortrait,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
      children: [
        // 추천 상품 섹션 제목과 더보기 버튼
        Padding(
          padding: AppStyles.defaultPadding, // 스타일에 맞춘 패딩 적용
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // 제목과 더보기 버튼을 양쪽으로 배치
            children: [
              Text('국한님을 위한 추천상품', style: AppStyles.headingStyle), // 섹션 제목
              Text(
                '더보기 >',
                style: AppStyles.bodyTextStyle
                    .copyWith(color: AppStyles.greyColor), // 더보기 버튼 스타일
              ),
            ],
          ),
        ),
        // 추천 상품 리스트뷰
        SizedBox(
          // 세로/가로 모드에 따라 높이 설정
          height: isPortrait ? 400 : 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // 가로 스크롤 설정
            itemCount: recommendedProducts.length, // 아이템 수
            padding: AppStyles.horizontalPadding, // 가로 패딩
            itemBuilder: (context, index) =>
                _buildProductCard(index), // 각 상품 카드 빌더
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(int index) {
    return Container(
      width: AppStyles.productCardWidth,
      margin: EdgeInsets.only(right: AppStyles.productCardSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 상품 이미지 - 수정된 부분
          Container(
            width: double.infinity,
            height: 200, // 고정된 높이 설정
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white, // 배경색 지정
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                recommendedProducts[index % recommendedProducts.length],
                fit: BoxFit.contain, // cover에서 contain으로 변경
              ),
            ),
          ),
          SizedBox(height: 8),

          // 나머지 위젯들은 동일...
          Text(
            '[트러블/민감] 아크네스 모공 클리어 젤 클렌저...',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodyTextStyle,
          ),
          SizedBox(height: 4),

          Row(
            children: [
              Text(
                '30%',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '12,600원',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '오늘드림',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'BEST',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: AppStyles.mainColor,
              ),
              SizedBox(width: 4),
              Text(
                '4.8',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '(1,234)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 1),
              IconButton(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
