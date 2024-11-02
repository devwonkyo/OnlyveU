import 'package:flutter/material.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_pricesection_widget.dart';
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_productlist_widget.dart';

class CartTabHeaderWidget extends StatelessWidget {
  final List<ProductModel> regularDeliveryItems;
  final List<ProductModel> pickupItems;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;
  final bool isAllSelected;
  final Function(bool?) onSelectAll;
  final Function(ProductModel) onRemoveItem;
  final Function(String, bool) updateQuantity;
  final Function(String, bool?) onUpdateSelection;
  final VoidCallback onDeleteSelected;
  final VoidCallback moveToPickup;
  final VoidCallback moveToRegularDelivery;
  final TabController tabController;

  const CartTabHeaderWidget({
    Key? key,
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
            updateQuantity: updateQuantity,
            onRemoveItem: onRemoveItem,
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
        ? Center(child: Text('픽업 상품이 없습니다.'))
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildCartHeader(context, false),
                CartProductListWidget(
                  items: pickupItems,
                  isPickup: true,
                  selectedItems: selectedItems,
                  itemQuantities: itemQuantities,
                  updateQuantity: updateQuantity,
                  onRemoveItem: onRemoveItem,
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                onChanged: onSelectAll,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text('전체'),
            ],
          ),
          Text(' | ', style: TextStyle(color: Colors.grey[300])),
          TextButton(
            onPressed: () {
              if (selectedItems.values.contains(true)) {
                if (isRegularDelivery) {
                  moveToPickup();
                } else {
                  moveToRegularDelivery();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('변경할 상품을 선택해주세요')),
                );
              }
            },
            child: Row(
              children: [
                Text(
                  '배송방법 변경',
                  style: TextStyle(color: Colors.black87),
                ),
                Icon(Icons.chevron_right, size: 20, color: Colors.black87),
              ],
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: onDeleteSelected,
            child: Text(
              '선택삭제',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
