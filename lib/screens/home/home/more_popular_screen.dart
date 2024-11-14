import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/utils/styles.dart';

class MorePopularScreen extends StatelessWidget {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(),
        title: Text(
          '연관 인기 상품',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(RefreshHomeData());
              },
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.5,
                ),
                itemCount: state.popularProducts.length,
                itemBuilder: (context, index) =>
                    _buildProductCard(state.popularProducts[index], context),
              ),
            );
          }
          return Center(child: Text('상품을 불러올 수 없습니다.'));
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, BuildContext context) {
    final originalPrice = int.tryParse(product.price) ?? 0;
    final discountedPrice =
        originalPrice * (100 - product.discountPercent) ~/ 100;

    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: product.productId),
      child: Container(
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
                child: Hero(
                  tag: 'product_${product.productId}',
                  child: Image.network(
                    product.productImageList.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Icon(Icons.error));
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),

            // 상품명
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

            // 가격 정보
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

            // 태그 - 가격과 별점 사이에 위치하도록 이동
            Row(
              children: [
                if (product.isPopular)
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
                if (product.isPopular && product.isBest) SizedBox(width: 6),
                if (product.isBest)
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

            // 좋아요와 장바구니 버튼
            Row(
              children: [
                //^ 기존 코드를 아래와 같이 수정
                FutureBuilder<String>(
                  future: OnlyYouSharedPreference().getCurrentUserId(),
                  builder: (context, snapshot) {
                    final userId = snapshot.data ?? 'temp_user_id';
                    final isFavorite = product.favoriteList.contains(userId);

                    return GestureDetector(
                      onTap: () async {
                        final currentUserId =
                            await OnlyYouSharedPreference().getCurrentUserId();
                        context
                            .read<HomeBloc>()
                            .add(ToggleProductFavorite(product, currentUserId));
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
                  onTap: () => _handleAddToCart(context, product),
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
      ),
    );
  }

  void _handleAddToCart(BuildContext context, ProductModel product) async {
    final currentUserId = await OnlyYouSharedPreference().getCurrentUserId();
    context.read<HomeBloc>().add(AddToCart(product.productId));

    // 성공/실패 상태에 따른 스낵바 표시
    context.read<HomeBloc>().stream.listen(
      (state) {
        if (state is HomeError || state is HomeSuccess) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state is HomeSuccess
                  ? state.message
                  : (state as HomeError).message),
              duration: Duration(milliseconds: 1000),
            ),
          );
        }
      },
    );
  }
}
