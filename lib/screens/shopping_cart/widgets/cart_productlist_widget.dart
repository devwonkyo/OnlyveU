import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/format_price.dart'; //천만위마다 점찍는거

import '../../../models/product_model.dart';

// CartProductListWidget: 장바구니에 담긴 상품 리스트를 보여주는 위젯
class CartProductListWidget extends StatelessWidget {
  final List<ProductModel> items; // 장바구니에 담긴 상품 목록
  final bool isPickup; // 픽업 여부를 나타내는 플래그
  final Map<String, bool> selectedItems; // 선택된 상품 정보 (key: 상품 ID, value: 선택 여부)
  final Map<String, int> itemQuantities; // 각 상품의 수량 정보
  final Function(String productId, bool increment)
      updateQuantity; // 상품 수량을 변경하는 함수
  final Function(ProductModel item) onRemoveItem; // 특정 상품을 제거하는 함수
  final Function(String productId, bool? value)
      onUpdateSelection; // 선택 상태를 업데이트하는 함수

  const CartProductListWidget({
    required this.items,
    required this.isPickup,
    required this.selectedItems,
    required this.itemQuantities,
    required this.updateQuantity,
    required this.onRemoveItem,
    required this.onUpdateSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // 상품 목록을 아이템 단위로 구성
      children: items.map((item) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.grey[300]!)), // 하단 경계선
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPickup) // 픽업인 경우 픽업 매장 표시
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('픽업 매장: 거여역점',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              // 상품 정보와 체크박스, 이미지 등을 포함한 행(Row) 구성
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상품 선택 여부를 나타내는 체크박스
                  Checkbox(
                    value: selectedItems[item.productId] ?? false,
                    onChanged: (value) =>
                        onUpdateSelection(item.productId, value), // 선택 상태 업데이트
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // 상품 이미지 표시
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImageList.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover, // 이미지가 꽉 차도록 설정
                      errorBuilder: (context, error, stackTrace) {
                        // 이미지 로딩 실패 시 대체 이미지
                        print('Error loading image: $error');
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        // 이미지 로딩 상태 표시
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12), // 이미지와 텍스트 사이의 간격
                  Expanded(
                    // 상품 이름 텍스트
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name, // 상품 이름
                          style: TextStyle(fontSize: 14),
                          maxLines: 2, // 이름이 길 경우 두 줄로 표시
                          overflow: TextOverflow.ellipsis, // 길면 생략 처리
                        ),
                      ],
                    ),
                  ),
                  // 상품 제거 버튼
                  IconButton(
                    icon: Icon(Icons.close, size: 20),
                    onPressed: () => onRemoveItem(item), // 상품 제거 함수 호출
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // 수량 조절 및 가격 표시 행
              Row(
                children: [
                  SizedBox(width: 50),
                  _buildQuantityControl(item), // 수량 조절 버튼
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 원래 가격 (할인 전)
                      Text(
                        '${formatPrice(item.price)}원',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough, // 취소선
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      // 할인된 가격 (최종 가격)
                      Text(
                        '${formatPrice(item.discountedPrice.toString())}원',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // _buildQuantityControl: 상품 수량을 증가/감소시킬 수 있는 컨트롤러
  Widget _buildQuantityControl(ProductModel item) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 수량 감소 버튼
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              icon: Icon(Icons.remove, size: 16),
              onPressed: () =>
                  updateQuantity(item.productId, false), // 수량 감소 함수 호출
              padding: EdgeInsets.zero,
            ),
          ),
          // 현재 수량 표시
          Container(
            width: 30,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              '${itemQuantities[item.productId] ?? 1}', // 현재 수량 (기본값: 1)
              style: TextStyle(fontSize: 14),
            ),
          ),
          // 수량 증가 버튼
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              icon: Icon(Icons.add, size: 16),
              onPressed: () =>
                  updateQuantity(item.productId, true), // 수량 증가 함수 호출
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
