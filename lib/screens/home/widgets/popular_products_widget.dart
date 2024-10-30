import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/models/history_item.dart';
import 'package:onlyveyou/utils/styles.dart';

// 인기 상품 목록을 보여주는 위젯
class PopularProductsWidget extends StatelessWidget {
  final List<HistoryItem> popularProducts; // 인기 상품 리스트
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
              Text('연관 인기 상품', style: AppStyles.headingStyle), // 섹션 제목
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
          height: isPortrait ? 340 : 240, // 세로/가로 모드에 따라 높이 설정
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // 가로 스크롤
            itemCount: popularProducts.length, // 아이템 수
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) => _buildProductCard(index, context),
          ),
        ),
      ],
    );
  }

  // 각 상품 카드를 생성하는 위젯
  Widget _buildProductCard(int index, BuildContext context) {
    // context 추가
    final item = popularProducts[index];
    return Container(
      width: 150, // 카드 너비 고정
      margin: EdgeInsets.only(right: 12), // 카드 간격
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 상품 이미지
          Container(
            width: 150, // 이미지 너비
            height: 150, // 이미지 높이
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.imageUrl, // HistoryItem의 이미지 URL 사용
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 8),

          // 2. 상품명
          Text(
            item.title, // HistoryItem의 제목 사용
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),

          // 3. 가격 정보
          Row(
            children: [
              if (item.discountRate != null)
                Text(
                  '${item.discountRate}%', // HistoryItem의 할인율 사용
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              SizedBox(width: 4),
              Text(
                '${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원', // HistoryItem의 가격 사용
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
              if (item.isBest) // isBest가 true일 때만 BEST 태그 표시
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
                '(${item.reviewCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')})',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 0),

          // 6. 좋아요와 장바구니 버튼
          Row(
            children: [
              IconButton(
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: item.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  context.read<HomeBloc>().add(ToggleProductFavorite(item));
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 12),
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
