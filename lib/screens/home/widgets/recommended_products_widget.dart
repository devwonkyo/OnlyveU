// widgets/recommended_products_widget.dart

import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/styles.dart';

class RecommendedProductsWidget extends StatelessWidget {
  final List<String> recommendedProducts;
  final bool isPortrait;

  RecommendedProductsWidget({
    required this.recommendedProducts,
    required this.isPortrait,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppStyles.defaultPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('국한님을 위한 추천상품', style: AppStyles.headingStyle),
              Text(
                '더보기 >',
                style: AppStyles.bodyTextStyle
                    .copyWith(color: AppStyles.greyColor),
              ),
            ],
          ),
        ),
        SizedBox(
          height: isPortrait ? 320 : 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedProducts.length,
            padding: AppStyles.horizontalPadding,
            itemBuilder: (context, index) => _buildProductCard(index),
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
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: AppStyles.defaultRadius,
              child: Image.asset(
                recommendedProducts[index % recommendedProducts.length],
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '[트러블/민감] 아크네스 모공 클리어 젤 클렌저...',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodyTextStyle,
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Text('30%', style: AppStyles.discountTextStyle),
              SizedBox(width: 4),
              Text('12,600원', style: AppStyles.priceTextStyle),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star, size: 14, color: AppStyles.mainColor),
              Text('4.8 (1,234)', style: AppStyles.smallTextStyle),
            ],
          ),
        ],
      ),
    );
  }
}
