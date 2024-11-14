import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/shopping_cart/shopping_cart_bloc.dart';
import 'package:onlyveyou/models/cart_model.dart';
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_pricesection_widget.dart';
import 'package:onlyveyou/utils/format_price.dart';

class CartBottomBarWidget extends StatelessWidget {
  final List<CartModel> currentItems;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;

  const CartBottomBarWidget({
    super.key,
    required this.currentItems,
    required this.selectedItems,
    required this.itemQuantities,
  });

  // 선택된 상품 개수 계산
  int _calculateSelectedCount() {
    return currentItems
        .where((item) => selectedItems[item.productId] == true)
        .map((item) => itemQuantities[item.productId] ?? 1)
        .fold(0, (sum, quantity) => sum + quantity);
  }

  @override
  Widget build(BuildContext context) {
    // 할인 전 총 금액 계산
    final originalPrice = CartPriceSectionWidget.calculateTotalOriginalPrice(
      items: currentItems,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );

    // 할인 후 총 금액 계산
    final discountedPrice =
        CartPriceSectionWidget.calculateTotalDiscountedPrice(
      items: currentItems,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );

    // 총 할인 금액 계산
    final totalDiscount = originalPrice - discountedPrice;

    // 선택된 총 상품 개수
    final totalSelectedCount = _calculateSelectedCount();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상품 금액 정보 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '총 $totalSelectedCount건',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (totalDiscount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${formatPrice(originalPrice.toString())}원',
                          style: TextStyle(
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '-${formatPrice(totalDiscount.toString())}원',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              Text(
                '${formatPrice(discountedPrice.toString())}원',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 선물하기/구매하기 버튼
          Row(
            children: [
              // 선물하기 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: totalSelectedCount > 0
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('선물하기 기능 준비중입니다.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    '선물하기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 구매하기 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: totalSelectedCount > 0
                      ? () async {
                          try {
                            final cartBloc = context.read<CartBloc>();
                            final order =
                                await cartBloc.getSelectedOrderItems();
                            if (order.items.isNotEmpty) {
                              print('Navigating to payment with order:');
                              print('- User ID: ${order.userId}');
                              print('- Order Type: ${order.orderType}');
                              print('- Total Items: ${order.items.length}');
                              print('- Total Price: ${order.totalPrice}');
                              context.push('/payment', extra: order);
                            }
                          } catch (e) {
                            print('Error processing order: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('주문 처리 중 오류가 발생했습니다.'),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    '구매하기 ($totalSelectedCount)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
////
// Expanded(
// // child: ElevatedButton(
// // // onPressed: 버튼 터치 시 실행될 콜백 함수
// // // totalSelectedCount > 0: 선택된 상품이 있는 경우에만 버튼 활성화
// // onPressed: totalSelectedCount > 0
// // ? () async {
// // try {
// // // 1. CartBloc에 접근하여 OrderModel 생성 요청
// // // context.read<CartBloc>(): 현재 위젯 트리에서 CartBloc 인스턴스를 가져옴
// // final cartBloc = context.read<CartBloc>();
// // // getSelectedOrderItems(): 선택된 카트 아이템으로 OrderModel을 생성하는 비동기 함수 호출
// // final order = await cartBloc.getSelectedOrderItems();
// //
// // // 2. 생성된 주문에 포함된 상품이 있는지 확인
// // if (order.items.isNotEmpty) {
// // // 디버깅을 위한 주문 정보 로그 출력
// // print('Navigating to payment with order:');
// // print('- User ID: ${order.userId}');          // 주문자 ID
// // print('- Order Type: ${order.orderType}');    // 배송/픽업 여부
// // print('- Total Items: ${order.items.length}'); // 주문 상품 개수
// // print('- Total Price: ${order.totalPrice}');   // 총 주문 금액
// //
// // // 3. go_router를 사용하여 결제 페이지로 네비게이션
// // context.push(
// // '/payment',           // 이동할 라우트 경로
// // extra: {'order': order}, // 라우트에 전달할 추가 데이터 (OrderModel)
// // );
// // }
// // } catch (e) {
// // // 에러 처리: 로그 출력 및 사용자 피드백
// // print('Error processing order: $e');
// // // ScaffoldMessenger: 스낵바를 표시하기 위한 Flutter의 위젯
// // ScaffoldMessenger.of(context).showSnackBar(
// // const SnackBar(
// // content: Text('주문 처리 중 오류가 발생했습니다.'),
// // ),
// // );
// // }
// // }
// //     : null, // 선택된 상품이 없으면 null을 할당하여 버튼 비활성화
// //
// // // 버튼의 스타일 설정
// // style: ElevatedButton.styleFrom(
// // backgroundColor: Colors.black,    // 버튼 배경색
// // padding: const EdgeInsets.symmetric(vertical: 16), // 상하 패딩
// // shape: RoundedRectangleBorder(    // 버튼 모양
// // borderRadius: BorderRadius.circular(4), // 모서리 둥글기
// // ),
// // ),
// //
// // // 버튼 내부 텍스트 위젯
// // child: Text(
// // '구매하기 ($totalSelectedCount)', // 선택된 상품 수를 포함한 텍스트
// // style: const TextStyle(
// // color: Colors.white,         // 텍스트 색상
// // foWeight: FontWeight.bold, // 텍스트 두께
// ),
// ),
// ),
// );
