import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/styles.dart';

// 인기 상품 목록을 보여주는 위젯
class PopularProductsWidget extends StatelessWidget {
  final List<String> popularProducts; // 인기 상품 이미지 경로 리스트
  final bool isPortrait; // 세로 모드 여부

  PopularProductsWidget({
    required this.popularProducts,
    required this.isPortrait,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
      children: [
        // 인기 상품 섹션 제목과 더보기 버튼
        Padding(
          padding: AppStyles.defaultPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최근 본 연관 인기 상품', style: AppStyles.headingStyle), // 섹션 제목
              Text(
                '더보기 >',
                style: AppStyles.bodyTextStyle
                    .copyWith(color: AppStyles.greyColor), // 더보기 버튼 스타일
              ),
            ],
          ),
        ),
        // 인기 상품 리스트뷰
        SizedBox(
          height: isPortrait ? 320 : 240, // 세로/가로 모드에 따라 높이 설정
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // 가로 스크롤
            itemCount: popularProducts.length, // 아이템 수
            padding: AppStyles.horizontalPadding,
            itemBuilder: (context, index) => _buildProductCard(index),
          ),
        ),
      ],
    );
  }

  // 각 상품 카드를 생성하는 위젯
  Widget _buildProductCard(int index) {
    return Container(
      width: AppStyles.productCardWidth, // 카드 너비
      margin: EdgeInsets.only(right: AppStyles.productCardSpacing), // 카드 간격
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          // 상품 이미지
          AspectRatio(
            aspectRatio: 1, // 정사각형 비율 유지
            child: ClipRRect(
              borderRadius: AppStyles.defaultRadius, // 이미지 모서리 둥글게 처리
              child: Image.asset(
                popularProducts[index % popularProducts.length], // 이미지 불러오기
                fit: BoxFit.cover, // 이미지 크기 조정 (빈 공간 없이 채우기)
              ),
            ),
          ),
          SizedBox(height: 8), // 이미지와 텍스트 간격
          // 상품 설명 텍스트
          Text(
            '[트러블/민감] 아크네스 모공 클리어 젤 클렌저...', // 상품 이름
            maxLines: 2, // 최대 2줄로 표시, 초과 시 생략(...)
            overflow: TextOverflow.ellipsis, // 텍스트가 넘칠 경우 생략 표시
            style: AppStyles.bodyTextStyle, // 텍스트 스타일
          ),
          SizedBox(height: 4),
          // 할인율과 가격 표시
          Row(
            children: [
              Text('30%', style: AppStyles.discountTextStyle), // 할인율
              SizedBox(width: 4),
              Text('12,600원', style: AppStyles.priceTextStyle), // 가격
            ],
          ),
          SizedBox(height: 4),
          // 별점과 리뷰 수
          Row(
            children: [
              Icon(Icons.star, size: 14, color: AppStyles.mainColor), // 별 아이콘
              Text('4.8 (1,234)', style: AppStyles.smallTextStyle), // 별점 및 리뷰 수
            ],
          ),
        ],
      ),
    );
  }
}
