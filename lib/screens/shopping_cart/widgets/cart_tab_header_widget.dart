import 'package:flutter/material.dart';
import 'package:onlyveyou/models/cart_model.dart';
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_pricesection_widget.dart';
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_productlist_widget.dart';

class CartTabHeaderWidget extends StatelessWidget {
  final List<CartModel> regularDeliveryItems;
  final List<CartModel> pickupItems;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;
  final bool isAllSelected;
  final bool isRegularDeliveryTab;
  final Function(bool?, bool) onSelectAll;
  final Function(String, bool) onRemoveItem;
  final Function(String, bool, bool) onUpdateQuantity;
  final Function(String, bool?) onUpdateSelection;
  final Function(bool) onDeleteSelected;
  final Function(List<String>) onMoveToPickup;
  final Function(List<String>) onMoveToRegularDelivery;
  final TabController tabController;

  const CartTabHeaderWidget({
    Key? key,
    required this.regularDeliveryItems,
    required this.pickupItems,
    required this.selectedItems,
    required this.itemQuantities,
    required this.isAllSelected,
    required this.isRegularDeliveryTab,
    required this.onSelectAll,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
    required this.onUpdateSelection,
    required this.onDeleteSelected,
    required this.onMoveToPickup,
    required this.onMoveToRegularDelivery,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: TabBar(
            controller: tabController,
            tabs: [
              Tab(text: '일반 배송(${regularDeliveryItems.length})'),
              Tab(text: '픽업(${pickupItems.length})'),
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _buildRegularDeliveryTab(context),
              _buildPickupTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegularDeliveryTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCartHeader(context, true),
          CartProductListWidget(
            items: regularDeliveryItems,
            isPickup: false,
            selectedItems: selectedItems,
            itemQuantities: itemQuantities,
            onUpdateQuantity: (productId, increment) =>
                onUpdateQuantity(productId, increment, false),
            onRemoveItem: (productId) => onRemoveItem(productId, false),
            onUpdateSelection: onUpdateSelection,
          ),
          CartPriceSectionWidget(
            items: regularDeliveryItems,
            selectedItems: selectedItems,
            itemQuantities: itemQuantities,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupTab(BuildContext context) {
    return pickupItems.isEmpty
        ? const Center(child: Text('픽업 상품이 없습니다.'))
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildCartHeader(context, false),
                CartProductListWidget(
                  items: pickupItems,
                  isPickup: true,
                  selectedItems: selectedItems,
                  itemQuantities: itemQuantities,
                  onUpdateQuantity: (productId, increment) =>
                      onUpdateQuantity(productId, increment, true),
                  onRemoveItem: (productId) => onRemoveItem(productId, true),
                  onUpdateSelection: onUpdateSelection,
                ),
                CartPriceSectionWidget(
                  items: pickupItems,
                  selectedItems: selectedItems,
                  itemQuantities: itemQuantities,
                ),
              ],
            ),
          );
  }

  Widget _buildCartHeader(BuildContext context, bool isRegularDelivery) {
    final currentItems = isRegularDelivery ? regularDeliveryItems : pickupItems;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Checkbox(
                value: isAllSelected,
                onChanged: (value) => onSelectAll(value, !isRegularDelivery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text('전체'),
            ],
          ),
          Text(' | ', style: TextStyle(color: Colors.grey[300])),
          TextButton(
            onPressed: () {
              final selectedIds = currentItems
                  .where((item) => selectedItems[item.productId] == true)
                  .map((item) => item.productId)
                  .toList();

              if (selectedIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('변경할 상품을 선택해주세요')),
                );
                return;
              }

              if (isRegularDelivery) {
                onMoveToPickup(selectedIds);
              } else {
                onMoveToRegularDelivery(selectedIds);
              }
            },
            child: Row(
              children: [
                Text(
                  isRegularDelivery ? '픽업으로 변경' : '일반배송으로 변경',
                  style: const TextStyle(color: Colors.black87),
                ),
                const Icon(Icons.chevron_right,
                    size: 20, color: Colors.black87),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => onDeleteSelected(!isRegularDelivery),
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
