import 'package:flutter/material.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_pricesection_widget.dart'; // 장바구니 가격 정보를 표시하는 위젯
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_productlist_widget.dart'; // 장바구니 상품 목록을 표시하는 위젯

// CartTabHeaderWidget: 장바구니 페이지의 상단 탭과 상품 목록을 표시하는 위젯
class CartTabHeaderWidget extends StatelessWidget {
  final List<ProductModel> regularDeliveryItems; // 일반 배송 아이템 리스트
  final List<ProductModel> pickupItems; // 픽업 아이템 리스트

  final Map<String, bool>
      selectedItems; // 선택된 아이템들을 저장하는 Map (key: 상품 ID, value: 선택 여부)
  final Map<String, int>
      itemQuantities; // 각 아이템의 수량을 저장하는 Map (key: 상품 ID, value: 수량)
  final bool isAllSelected; // 전체 항목 선택 여부
  final Function(bool?) onSelectAll; // 전체 선택/해제 함수
  final Function(ProductModel) onRemoveItem; // 특정 상품을 제거하는 함수
  final Function(String, bool) updateQuantity; // 아이템 수량 업데이트 함수
  final Function(String, bool?) onUpdateSelection; // 특정 아이템의 선택 상태 업데이트 함수
  final VoidCallback onDeleteSelected; // 선택된 아이템 삭제 함수
  final VoidCallback moveToPickup; // 선택한 아이템을 픽업으로 이동하는 함수
  final VoidCallback moveToRegularDelivery; // 선택한 아이템을 일반 배송으로 이동하는 함수
  final TabController tabController; // 일반 배송과 픽업을 전환할 수 있는 탭 컨트롤러

  const CartTabHeaderWidget({
    super.key,
    required this.regularDeliveryItems,
    required this.pickupItems,
    required this.selectedItems,
    required this.itemQuantities,
    required this.isAllSelected,
    required this.onSelectAll,
    required this.onRemoveItem,
    required this.updateQuantity,
    required this.onUpdateSelection,
    required this.onDeleteSelected,
    required this.moveToPickup,
    required this.moveToRegularDelivery,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 탭바 - 일반 배송과 픽업
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!), // 탭 하단에 회색 경계선
            ),
          ),
          child: TabBar(
            controller: tabController, // 전달받은 탭 컨트롤러로 탭 전환을 제어
            tabs: [
              Tab(text: '일반 배송(${regularDeliveryItems.length})'), // 일반 배송 탭
              Tab(text: '픽업(${pickupItems.length})'), // 픽업 탭
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
          ),
        ),
        // 탭 내용 - 일반 배송 및 픽업 상품 리스트
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _buildRegularDeliveryTab(context), // 일반 배송 탭 내용- 뒤에 위젯으로
              _buildPickupTab(context), // 픽업 탭 내용
            ],
          ),
        ),
      ],
    );
  }

  // 일반 배송 탭에 표시될 콘텐츠 빌드 함수
  Widget _buildRegularDeliveryTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCartHeader(context, false), // 장바구니 상단에 전체 선택 및 삭제 기능
          CartProductListWidget(
            // 상품 목록을 표시하는 위젯
            items: regularDeliveryItems,
            isPickup: false, // 일반 배송인지 픽업인지 구분
            selectedItems: selectedItems,
            itemQuantities: itemQuantities,
            updateQuantity: updateQuantity, // 상품 수량 변경 함수
            onRemoveItem: onRemoveItem, // 상품 제거 함수
            onUpdateSelection: onUpdateSelection, // 상품 선택 여부 변경 함수
          ),
          CartPriceSectionWidget(
            // 선택된 상품의 가격 정보를 표시하는 위젯
            items: regularDeliveryItems,
            selectedItems: selectedItems,
            itemQuantities: itemQuantities,
          ),
        ],
      ),
    );
  }

  // 픽업 탭에 표시될 콘텐츠 빌드 함수
  Widget _buildPickupTab(BuildContext context) {
    return pickupItems.isEmpty
        ? const Center(child: Text('픽업 상품이 없습니다.')) // 픽업 상품이 없을 때 메시지 표시
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildCartHeader(context, false), // 장바구니 상단에 전체 선택 및 삭제 기능
                CartProductListWidget(
                  // 상품 목록을 표시하는 위젯
                  items: pickupItems,
                  isPickup: true, // 픽업 상품임을 표시
                  selectedItems: selectedItems,
                  itemQuantities: itemQuantities,
                  updateQuantity: updateQuantity,
                  onRemoveItem: onRemoveItem,
                  onUpdateSelection: onUpdateSelection,
                ),
                CartPriceSectionWidget(
                  // 선택된 상품의 가격 정보를 표시하는 위젯
                  items: pickupItems,
                  selectedItems: selectedItems,
                  itemQuantities: itemQuantities,
                ),
              ],
            ),
          );
  }

  // 장바구니 상단의 전체 선택, 삭제, 배송 방법 변경 기능을 제공하는 헤더
  Widget _buildCartHeader(BuildContext context, bool isRegularDelivery) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // 전체 선택 체크박스와 텍스트
          Row(
            children: [
              Checkbox(
                value: isAllSelected, // 전체 선택 여부
                onChanged: onSelectAll, // 전체 선택 상태 변경 함수
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text('전체'), // '전체' 텍스트
            ],
          ),
          Text(' | ', style: TextStyle(color: Colors.grey[300])), // 구분자
          // 배송 방법 변경 버튼
          TextButton(
            onPressed: () {
              if (selectedItems.values.contains(true)) {
                if (tabController.index == 0) {
                  // isRegularDelivery 대신 tabController.index로 확인
                  moveToPickup();
                } else {
                  moveToRegularDelivery();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('변경할 상품을 선택해주세요')),
                );
              }
            },
            child: Row(
              children: [
                Text(
                  tabController.index == 0
                      ? '픽업으로 변경'
                      : '일반배송으로 변경', // 탭에 따라 텍스트 변경
                  style: const TextStyle(color: Colors.black87),
                ),
                const Icon(Icons.chevron_right,
                    size: 20, color: Colors.black87),
              ],
            ),
          ),
          const Spacer(),
          // 선택 삭제 버튼
          TextButton(
            onPressed: () {
              // 선택된 상품 삭제 시 현재 탭 정보 전달
              onDeleteSelected();
            },
            child: const Text(
              '선택삭제',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
