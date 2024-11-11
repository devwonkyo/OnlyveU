import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/utils/styles.dart';

class PopularProductsWidget extends StatelessWidget {
  final List<ProductModel> popularProducts;
  final bool isPortrait;

  PopularProductsWidget({
    required this.popularProducts,
    required this.isPortrait,
    Key? key,
  }) : super(key: key);

  String _formatPrice(String price) {
    try {
      return price.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    } catch (e) {
      return '0';
    }
  }

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
              Text('연관 인기 상품', style: AppStyles.headingStyle),
              GestureDetector(
                onTap: () => context.push('/more-popular'),
                child: Text(
                  '더보기 >',
                  style: AppStyles.bodyTextStyle
                      .copyWith(color: AppStyles.greyColor),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: isPortrait ? 340 : 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularProducts.length,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) => _buildProductCard(index, context),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(int index, BuildContext context) {
    final product = popularProducts[index];
    final originalPrice = int.tryParse(product.price) ?? 0;
    final discountedPrice =
        originalPrice * (100 - product.discountPercent) ~/ 100;

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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.productImageList.isNotEmpty
                  ? Image.network(
                      product.productImageList.first,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Icon(Icons.error));
                      },
                    )
                  : Image.asset(
                      'assets/default_image.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(height: 8),

          // 2. 상품명
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),

          // 3. 가격 정보
          if (product.discountPercent > 0)
            Text(
              '${_formatPrice(product.price)}원',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          SizedBox(height: 2),
          Row(
            children: [
              if (product.discountPercent > 0)
                Text(
                  '${product.discountPercent}%',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              SizedBox(width: 4),
              Text(
                '${_formatPrice(discountedPrice.toString())}원',
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
              if (product.isPopular) // item 대신 product 사용
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '인기',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                ),
              SizedBox(width: 4),
              if (product.isBest) // item 대신 product 사용
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
                product.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 2),
              Text(
                '(${product.reviewList.length})',
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
              FutureBuilder<String>(
                // SharedPreferences에서 userId를 가져오는 부분 추가
                future: OnlyYouSharedPreference().getCurrentUserId(),
                builder: (context, snapshot) {
                  final userId = snapshot.data ?? 'temp_user_id';
                  return GestureDetector(
                    onTap: () async {
                      final prefs = OnlyYouSharedPreference();
                      final currentUserId = await prefs.getCurrentUserId();
                      context.read<HomeBloc>().add(
                            ToggleProductFavorite(product, currentUserId),
                          );
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      child: Icon(
                        product.favoriteList
                                .contains(userId) // 익스텐션 대신 직접 리스트 체크
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color: product.favoriteList.contains(userId)
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 25),
              GestureDetector(
                onTap: () async {
                  final currentUserId =
                      await OnlyYouSharedPreference().getCurrentUserId();
                  context
                      .read<HomeBloc>()
                      .add(AddToCart(product.productId, currentUserId));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 1),
                      content: Text('장바구니에 추가되었습니다.'),
                    ),
                  );
                },
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
