import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';
import 'package:onlyveyou/models/product_model.dart'; // ProductModel로 수정
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/utils/styles.dart';

class MoreRecommendedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(),
        title: Text(
          '국한님을 위한 추천상품',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => context.pop('/home'),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            return GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                childAspectRatio: 0.45,
              ),
              itemCount: state.recommendedProducts.length,
              itemBuilder: (context, index) =>
                  _buildProductCard(state.recommendedProducts[index], context),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // ProductModel 타입을 사용하도록 수정
  Widget _buildProductCard(ProductModel item, BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.productImageList.isNotEmpty
                    ? Image.network(
                        item.productImageList[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                              child: Icon(Icons.error)); // 이미지 로딩 실패 시 아이콘 표시
                        },
                      )
                    : Image.asset(
                        'assets/default.png', // 로컬 기본 이미지
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          SizedBox(height: 8),

          // 상품명
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

          // 할인 전 가격 (위쪽에 표시)
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

          // 할인 후 가격과 할인률
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

          // 태그 (인기, BEST 등)
          Row(
            children: [
              if (item.tagList.contains('popular'))
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
              if (item.tagList.contains('popular')) SizedBox(width: 4),
              if (item.tagList.contains('BEST'))
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

          // 별점과 리뷰 수
          Row(
            children: [
              Icon(Icons.star, size: 12, color: AppStyles.mainColor),
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

          // 좋아요와 장바구니 버튼
          Row(
            children: [
              //^ 기존 코드를 아래와 같이 수정
              FutureBuilder<String>(
                future: OnlyYouSharedPreference().getCurrentUserId(),
                builder: (context, snapshot) {
                  final userId = snapshot.data ?? 'temp_user_id';
                  final isFavorite = item.favoriteList.contains(userId);

                  return GestureDetector(
                    onTap: () async {
                      final currentUserId =
                          await OnlyYouSharedPreference().getCurrentUserId();
                      context
                          .read<HomeBloc>()
                          .add(ToggleProductFavorite(item, currentUserId));
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? Colors.red : Colors.grey,
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
                      .add(AddToCart(item.productId, currentUserId));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('장바구니에 추가되었습니다.')),
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
