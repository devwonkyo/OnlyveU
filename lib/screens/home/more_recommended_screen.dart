import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/models/history_item.dart';
import 'package:onlyveyou/utils/styles.dart';

class MoreRecommendedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(), // leading 부분 제거
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
            onPressed: () => context.pop('/home'), // 홈 화면으로 이동
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

  Widget _buildProductCard(HistoryItem item, BuildContext context) {
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
              child: Image.asset(
                item.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 8),

          // 상품명
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),

          // 가격 정보
          if (item.originalPrice != null)
            Text(
              '${item.originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          SizedBox(height: 2),
          Row(
            children: [
              if (item.discountRate != null)
                Text(
                  '${item.discountRate}%',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              SizedBox(width: 4),
              Text(
                '${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),

          // 태그
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
                '(${item.reviewCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')})',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),

          // 좋아요와 장바구니 버튼
          // 6. 좋아요와 장바구니 버튼
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.read<HomeBloc>().add(ToggleProductFavorite(item));
                },
                child: Container(
                  width: 20,
                  height: 20,
                  child: Icon(
                    item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: item.isFavorite ? Colors.red : Colors.grey,
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
