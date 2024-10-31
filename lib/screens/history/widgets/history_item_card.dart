// HistoryItemCard: 히스토리 목록의 각 아이템을 보여주는 위젯
import 'package:flutter/material.dart';
import 'package:onlyveyou/models/history_item.dart';

class HistoryItemCard extends StatelessWidget {
  // 필요한 데이터와 콜백 함수들을 선언
  final HistoryItem item; // 표시할 아이템 데이터
  final bool isEditing; // 편집 모드 여부
  final VoidCallback onDelete; // 삭제 버튼 클릭 시 실행할 함수
  final VoidCallback onToggleFavorite; // 좋아요 버튼 클릭 시 실행할 함수

  // 생성자: 필수 매개변수들을 받음
  const HistoryItemCard({
    required this.item,
    required this.isEditing,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      // 아이템 카드 하단에 구분선 추가
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 1. 상품 이미지 부분
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // 이미지 모서리 둥글게
            child: Image.asset(
              item.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover, // 이미지가 영역에 꽉 차게 표시
            ),
          ),
          SizedBox(width: 16), // 이미지와 텍스트 사이 간격

          // 2. 상품 정보 부분
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2.1 상품 제목
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2, // 최대 2줄까지만 표시
                  overflow: TextOverflow.ellipsis, // 넘치는 텍스트는 ...으로 표시
                ),
                SizedBox(height: 4),

                // 2.2 원래 가격 (할인 전 가격) - 있는 경우에만 표시
                if (item.originalPrice != null)
                  Text(
                    // 천 단위마다 콤마 추가하는 정규식 사용
                    '${item.originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough, // 취소선 추가
                      decorationColor: Colors.grey,
                      decorationThickness: 1.5,
                    ),
                  ),
                SizedBox(height: 2),

                // 2.3 할인율과 현재 가격
                Row(
                  children: [
                    // 할인율 표시 (있는 경우에만)
                    if (item.discountRate != null)
                      Text(
                        '${item.discountRate}%',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    SizedBox(width: 8),
                    // 현재 가격
                    Text(
                      '${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // 2.4 태그 표시 (오늘드림, BEST 등)
                Row(
                  children: [
                    // '오늘드림' 태그
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '오늘드림',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    // BEST 태그 (상품이 BEST인 경우에만 표시)
                    if (item.isBest)
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'BEST',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 3. 오른쪽 버튼들 (편집 모드에 따라 달라짐)
          Column(
            children: [
              if (isEditing)
                // 편집 모드일 때는 삭제 버튼 표시
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: onDelete,
                )
              else
                // 일반 모드일 때는 좋아요와 장바구니 버튼 표시
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        item.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: item.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: onToggleFavorite,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // TODO: 장바구니 담기 기능 구현
                        print('장바구니에 담기: ${item.title}');
                      },
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
